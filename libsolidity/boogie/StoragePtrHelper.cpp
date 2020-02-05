#include <libsolidity/boogie/ASTBoogieUtils.h>
#include <libsolidity/boogie/BoogieContext.h>
#include <libsolidity/boogie/StoragePtrHelper.h>

using namespace std;
using namespace dev;
using namespace dev::solidity;
using namespace langutil;

namespace bg = boogie;

namespace dev
{
namespace solidity
{
StoragePtrHelper::PackResult StoragePtrHelper::packToLocalPtr(Expression const* expr, bg::Expr::Ref bgExpr, BoogieContext& context)
{
	PackResult result {nullptr, {}};
	if (!dynamic_cast<StructType const*>(expr->annotation().type) &&
		!dynamic_cast<ArrayType const*>(expr->annotation().type) &&
		!dynamic_cast<MappingType const*>(expr->annotation().type))
	{
		context.reportError(expr, "Expected array or struct type");
		return PackResult{context.freshTempVar(context.errType()), {}};
	}
	packInternal(expr, bgExpr, context, result);
	if (result.ptr)
		return result;

	context.reportError(expr, "Unsupported expression for packing into local pointer");
	return PackResult{context.freshTempVar(context.errType()), {}};
}

void StoragePtrHelper::packInternal(Expression const* expr, bg::Expr::Ref bgExpr, BoogieContext& context, PackResult& result)
{
	// Packs an expression (path to storage) into a local pointer as an array
	// The general idea is to associate each state variable and member with an index
	// so that the path can be encoded as an integer array.
	//
	// Example:
	// contract C {
	//   struct T { int z; }
	//   struct S {
	//     T t1;     --> 0
	//     T[] ts;   --> 1 + array index
	//   }
	//
	//   T t1;       --> 0
	//   S s1;       --> 1
	//   S[] ss;     --> 2 + array index
	// }
	//
	// t1 becomes [0]
	// s1.t1 becomes [1, 0]
	// ss[5].ts[3] becomes [2, 5, 1, 3]

	// Function calls return pointers, no need to pack, just copy the return value
	if (dynamic_cast<FunctionCall const*>(expr))
	{
		auto ptr = context.freshTempVar(context.localPtrType());
		result.ptr = ptr;
		result.stmts.push_back(bg::Stmt::assign(ptr->getRefTo(), bgExpr));
		return;
	}
	// Identifier: search for matching state variable in the contract
	if (auto idExpr = dynamic_cast<Identifier const*>(expr))
	{
		auto ptr = context.freshTempVar(context.localPtrType());
		// Collect all variables from all contracts that can see the struct
		vector<VariableDeclaration const*> vars;
		for (auto contr: context.stats().allContracts())
		{
			auto subVars = ASTNode::filteredNodes<VariableDeclaration>(contr->subNodes());
			vars.insert(vars.end(), subVars.begin(), subVars.end());
		}
		for (unsigned i = 0; i < vars.size(); ++i)
		{
			// If found, put its index into the packed array
			if (vars[i] == idExpr->annotation().referencedDeclaration)
			{
				// Must be the first element in the packed array
				solAssert(!result.ptr, "Reassignment of packed pointer");
				solAssert(result.stmts.empty(), "Non-empty packing statements");
				result.ptr = ptr;
				result.stmts.push_back(bg::Stmt::assign(
						bg::Expr::arrsel(ptr->getRefTo(), context.intLit(0, 256)),
						context.intLit(i, 256)));
				return;
			}
		}
	}
	// Member access: process base recursively, then find matching member
	else if (auto memAccExpr = dynamic_cast<MemberAccess const*>(expr))
	{
		auto bgMemAccExpr = dynamic_pointer_cast<bg::DtSelExpr const>(bgExpr);
		solAssert(bgMemAccExpr, "Expected Boogie member access expression");
		packInternal(&memAccExpr->expression(), bgMemAccExpr->getBase(), context, result);
		solAssert(result.ptr, "Empty pointer from subexpression");
		auto eStructType = dynamic_cast<StructType const*>(memAccExpr->expression().annotation().type);
		solAssert(eStructType, "Trying to pack member of non-struct expression");
		auto members = eStructType->structDefinition().members();
		for (unsigned i = 0; i < members.size(); ++i)
		{
			// If matching member found, put index in next position of the packed array
			if (members[i].get() == memAccExpr->annotation().referencedDeclaration)
			{
				unsigned nextPos = result.stmts.size();
				result.stmts.push_back(
						bg::Stmt::assign(
								bg::Expr::arrsel(result.ptr->getRefTo(), context.intLit(nextPos, 256)),
								context.intLit(i, 256)));
				return;
			}
		}
	}
	// Arrays and mappings: process base recursively, then store index expression in next position
	// in the packed array
	else if (auto idxExpr = dynamic_cast<IndexAccess const*>(expr))
	{
		auto bgIdxAccExpr = dynamic_pointer_cast<bg::ArrSelExpr const>(bgExpr);
		solAssert(bgIdxAccExpr, "Expected Boogie index access expression");
		bg::Expr::Ref base = bgIdxAccExpr->getBase();

		// Base has to be extracted in two steps for arrays, because an array is
		// actually a datatype with the actual array and its length
		if (idxExpr->baseExpression().annotation().type->category() == Type::Category::Array)
		{
			auto bgDtSelExpr = dynamic_pointer_cast<bg::DtSelExpr const>(bgIdxAccExpr->getBase());
			solAssert(bgIdxAccExpr, "Expected Boogie member access expression below indexer");
			base = bgDtSelExpr->getBase();
		}

		// Report error for unsupported index types
		auto idxType = idxExpr->indexExpression()->annotation().type->category();
		if (idxType == Type::Category::StringLiteral || idxType == Type::Category::Array)
		{
			context.reportError(idxExpr->indexExpression(), "Unsupported type for index in local pointer");
			return;
		}

		packInternal(&idxExpr->baseExpression(), base, context, result);
		solAssert(result.ptr, "Empty pointer from subexpression");
		unsigned nextPos = result.stmts.size();
		result.stmts.push_back(bg::Stmt::assign(
				bg::Expr::arrsel(result.ptr->getRefTo(), context.intLit(nextPos, 256)),
				bgIdxAccExpr->getIdx()));
		return;
	}

	context.reportError(expr, "Unsupported expression for packing into local pointer");
}

bg::Expr::Ref StoragePtrHelper::unpackLocalPtr(Expression const* ptrExpr, boogie::Expr::Ref ptrBgExpr, BoogieContext& context)
{
	auto result = unpackInternal(ptrExpr, ptrBgExpr, context.currentContract(), 0, nullptr, context);
	if (!result)
		context.reportError(ptrExpr, "Nothing to unpack, perhaps there are no instances of the type");
	return result;
}

bg::Expr::Ref StoragePtrHelper::unpackInternal(Expression const* ptrExpr, boogie::Expr::Ref ptrBgExpr, Declaration const* decl, int depth, bg::Expr::Ref base, BoogieContext& context)
{
	// Unpacks a local storage pointer represented as an array of integers
	// into a conditional expression. The general idea is the opposite of packing:
	// go through each state variable (recursively for complex types) and associate
	// a conditional expression. For the example in pack, unpacking an array [arr]
	// would be like the following:
	// ite(arr[0] == 0, t1,
	// ite(arr[0] == 1,
	//   ite(arr[1] == 0, s1.t1, s1.ts[arr[2]], ... )))

	// Contract: go through state vars and create conditional expression recursively
	if (dynamic_cast<ContractDefinition const*>(decl))
	{
		auto structType = dynamic_cast<StructType const*>(ptrExpr->annotation().type);
		auto arrayType = dynamic_cast<ArrayType const*>(ptrExpr->annotation().type);
		auto mapType = dynamic_cast<MappingType const*>(ptrExpr->annotation().type);
		solAssert(structType || arrayType || mapType, "Expected array, mapping or struct type when unpacking");
		// Collect all variables from all contracts that can see the struct
		vector<VariableDeclaration const*> vars;
		for (auto contr: context.stats().allContracts())
		{
			auto subVars = ASTNode::filteredNodes<VariableDeclaration>(contr->subNodes());
			vars.insert(vars.end(), subVars.begin(), subVars.end());
		}

		// Default context (if no state var to unpack to)
		bg::Expr::Ref unpackedExpr = nullptr;
		if (structType)
			unpackedExpr = bg::Expr::arrsel(context.getDefaultStorageContext(structType)->getRefTo(),
					bg::Expr::arrsel(ptrBgExpr, context.intLit(1, 256)));
		else if (arrayType)
			unpackedExpr = bg::Expr::arrsel(context.getDefaultStorageContext(arrayType)->getRefTo(),
				bg::Expr::arrsel(ptrBgExpr, context.intLit(1, 256)));
		for (unsigned i = 0; i < vars.size(); ++i)
		{
			auto subExpr = unpackInternal(ptrExpr, ptrBgExpr, vars[i], depth+1,
					bg::Expr::arrsel(bg::Expr::id(context.mapDeclName(*vars[i])), context.boogieThis()->getRefTo()), context);
			if (subExpr)
			{
				if (unpackedExpr)
					unpackedExpr = bg::Expr::cond(
							bg::Expr::eq(bg::Expr::arrsel(ptrBgExpr, context.intLit(depth, 256)), context.intLit(i, 256)),
							subExpr, unpackedExpr);
				else
					unpackedExpr = subExpr;
			}
		}
		return unpackedExpr;
	}
	// Variable (state var or struct member)
	else if (auto varDecl = dynamic_cast<VariableDeclaration const*>(decl))
	{
		auto targetStructTp = dynamic_cast<StructType const*>(ptrExpr->annotation().type);
		auto targetArrayTp = dynamic_cast<ArrayType const*>(ptrExpr->annotation().type);
		auto targetMapTp = dynamic_cast<MappingType const*>(ptrExpr->annotation().type);
		solAssert(targetStructTp || targetArrayTp || targetMapTp, "Expected array, mapping or struct type when unpacking");
		auto declTp = varDecl->type();

		// Get rid of arrays and mappings by indexing into them
		while (declTp->category() == Type::Category::Array || declTp->category() == Type::Category::Mapping)
		{
			if (auto arrType = dynamic_cast<ArrayType const*>(declTp))
			{
				// Found a variable with a matching type, just return
				if (targetArrayTp && targetArrayTp->isImplicitlyConvertibleTo(*arrType))
					return base;
				auto bgType = context.toBoogieType(arrType->baseType(), ptrExpr);
				base = bg::Expr::arrsel(
						context.getInnerArray(base, context.toBoogieType(arrType->baseType(), ptrExpr)),
						bg::Expr::arrsel(ptrBgExpr, context.intLit(depth, 256)));
				declTp = arrType->baseType();
			}
			else if (auto mapType = dynamic_cast<MappingType const*>(declTp))
			{
				// Found a variable with a matching type, just return
				if (targetMapTp && targetMapTp->isImplicitlyConvertibleTo(*mapType))
					return base;
				base = bg::Expr::arrsel(base, bg::Expr::arrsel(ptrBgExpr, context.intLit(depth, 256)));
				declTp = mapType->valueType();
			}
			else
				solAssert(false, "Expected array or mapping type");
			depth++;
		}

		auto declStructTp = dynamic_cast<StructType const*>(declTp);

		// Found a variable with a matching type, just return
		if (targetStructTp && declStructTp && targetStructTp->structDefinition() == declStructTp->structDefinition())
		{
			return base;
		}
		// Otherwise if it is a struct, go through members and recurse
		if (declStructTp)
		{
			auto members = declStructTp->structDefinition().members();
			bg::Expr::Ref expr = nullptr;
			for (unsigned i = 0; i < members.size(); ++i)
			{
				auto baseForSub = bg::Expr::dtsel(base,
						context.mapDeclName(*members[i]),
						context.getStructConstructor(&declStructTp->structDefinition()),
						dynamic_pointer_cast<bg::DataTypeDecl>(context.getStructType(&declStructTp->structDefinition(), DataLocation::Storage)));
				auto subExpr = unpackInternal(ptrExpr, ptrBgExpr, members[i].get(), depth+1, baseForSub, context);
				if (subExpr)
				{
					if (!expr)
						expr = subExpr;
					else
						expr = bg::Expr::cond(
								bg::Expr::eq(bg::Expr::arrsel(ptrBgExpr, context.intLit(depth, 256)), context.intLit(i, 256)),
								subExpr, expr);
				}
			}
			return expr;
		}
	}
	return nullptr;
}
}

}