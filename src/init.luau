--[=[
	@class TableUtil
	
	루아 테이블을 다룰 때 자주 사용하는 유틸리티 함수를 묶어 제공합니다.
	배열과 딕셔너리 구조를 간결하게 조작할 수 있도록 도와줍니다.
]=]

-- t-util for Lua 5.1 by Loominatrx
-- Compatible with Luau and Vanilla Lua.

-- Lua's table references
local insert, remove, move = table.insert, table.remove, table.move
local pack, unpack, concat = table.pack, table.unpack, table.concat
local random = math.random

-- Luau's table references
local tfind = table.find
local create = table.create
local clear = table.clear

-- New table
local TableUtil = {}

--[=[
	테이블에 들어 있는 요소 수를 반환합니다.
	@param tbl - 요소를 셀 테이블.
	@return number - 요소 개수.
]=]
function TableUtil.count(tbl: { any }): number
	local n = 0
	for _ in tbl do
		n = n + 1
	end
	return n
end

--[=[
	중첩 테이블을 모두 탐색해 요소 수를 계산합니다.
	@param tbl - 요소를 셀 테이블.
	@return - 모든 하위 요소를 포함한 개수.
]=]
function TableUtil.deepCount(tbl: { any }): number
	local n = 0
	for _, v in pairs(tbl) do
		n = type(v) == "table" and n + TableUtil.deepCount(v) or n + 1
	end
	return n
end

--[=[
	테이블에 값이 포함되어 있는지 확인합니다.
	@param tbl - 검색할 테이블.
	@param value any -- 찾을 값.
	@return boolean -- 값이 존재하면 true.
]=]
function TableUtil.includes(tbl: { any }, value): boolean
	for _, v in next, tbl do
		if v == value then
			return true
		end
	end
	return false
end

--[=[
	키가 1..n 형태인지 검사합니다.
	@param tbl - 검사할 테이블.
	@return boolean -- 배열 형태면 true.
]=]
function TableUtil.isArray(tbl: { any }): boolean
	-- Make sure that all keys are positive integers
	for key, value in pairs(tbl) do
		if type(key) ~= "number" or key % 1 ~= 0 or key < 1 then
			return false
		end
	end

	return true
end

--[=[
	배열이 아닌 사전 형태인지 검사합니다.
	@param tbl - 검사할 테이블.
	@return boolean -- 사전 형태면 true.
]=]
function TableUtil.isDict(tbl: { any }): boolean
	return not TableUtil.isArray(tbl)
end

--[=[
	모든 하위 테이블까지 재귀적으로 복제합니다.
	@param tbl - 복제할 테이블.
	@return - 깊은 복사본.
]=]
function TableUtil.deepClone<T>(tbl: T): T
	local ret = table.clone(tbl :: any) :: any
	for k, v in ret do
		if typeof(v) == "table" then
			ret[k] = TableUtil.deepClone(v)
		end
	end
	return ret
end

--[=[
	배열형 테이블을 원본에서 역순으로 뒤집습니다.
	@param tbl - 역순으로 바꿀 배열.
]=]
function TableUtil.reverse<T>(tbl: { T }): { T }
	if TableUtil.isEmpty(tbl) then
		error("	bl` must not be empty!", 2)
	elseif TableUtil.isDict(tbl) then
		error("	bl` must be a array-like table!", 2)
	end

	for i = 1, #tbl do
		insert(tbl, i, remove(tbl))
	end
end

--[=[
	원본을 유지한 채 역순 배열을 반환합니다.
	@param tbl - 복제 대상 배열
	@return - 역순 배열 복사본
]=]
function TableUtil.reversed<T>(tbl: { T }): { T }
	if TableUtil.isEmpty(tbl) then
		error("	bl` must not be empty!", 2)
	elseif TableUtil.isDict(tbl) then
		error("	bl` must be a array-like table!", 2)
	end

	local ret = {}
	for i = #tbl, 1, -1 do
		insert(ret, tbl[i])
	end
	return ret
end

--[=[
	테이블의 키를 배열로 반환합니다.
	@param tbl - 키를 추출할 테이블.
	@return - 키 배열.
]=]
function TableUtil.keys<T>(tbl: { [T]: any }): { T }
	local ret = {}
	for k in pairs(tbl) do
		insert(ret, k)
	end
	return ret
end

--[=[
	테이블의 값을 배열로 반환합니다.
	@param tbl - 값을 추출할 테이블.
	@return - 값 배열.
]=]
function TableUtil.values<T>(tbl: { [any]: T }): { T }
	local ret = {}
	for _, v in pairs(tbl) do
		insert(ret, v)
	end
	return ret
end

--[=[
	배열형 테이블에서 임의의 인덱스와 값을 돌려줍니다.
	@param tbl - 대상 배열.
	@return - 선택된 인덱스
	@return - 선택된 값
]=]
function TableUtil.randomIpair<T>(tbl: { T }): (number, T)
	local i = random(#tbl)
	return i, tbl[i]
end

--[=[
	사전형 테이블에서 임의의 키와 값을 돌려줍니다.
	@param tbl - 대상 테이블
	@return - 선택된 키
	@return - 선택된 값
]=]
function TableUtil.randomPair<T>(tbl: { [any]: T }): (any, T)
	local rand = random(TableUtil.count(tbl))
	local n = 0
	for k, v in pairs(tbl) do
		n = n + 1
		if n == rand then
			return k, v
		end
	end

	return
end

--[=[
	배열에서 지정한 구간을 잘라 새 배열로 돌려줍니다.
	@param tbl - 대상 배열
	@param start - 시작 인덱스
	@param stop - 끝 인덱스
	@param step - 걸음
	@return - 잘라낸 배열
]=]
function TableUtil.slice<T>(tbl: { T }, start: number?, stop: number?, step: number?): T
	local ret = {}
	for i = start or 1, stop or #tbl, step or 1 do
		insert(ret, tbl[i])
	end
	return ret
end

--[=[
	조건에 맞는 첫 번째 값을 반환합니다.
	@param tbl - 검색할 테이블
	@param testFn - 필터 함수
	@return - 조건을 만족하는 값
]=]
function TableUtil.findValue<K, V>(tbl: { [K]: V }, testFn: (value: V, key: K) -> boolean): V?
	for key, value in pairs(tbl) do
		if testFn(value, key) == true then
			return value
		end
	end
	return nil
end

--[=[
	조건에 맞는 첫 번째 키를 반환합니다.
	@param tbl - 검색할 테이블.
	@param testFn - 필터 함수.
	@return - 조건을 만족하는 키.
]=]
function TableUtil.findIndex<K, V>(tbl: { [K]: V }, testFn: (value: V, key: K) -> boolean): K?
	for key, value in pairs(tbl) do
		if testFn(value, key) == true then
			return key
		end
	end
	return nil
end

--[=[
	조건에 맞는 항목만 모아 새 테이블을 만들습니다.
	@param tbl - 대상 테이블.
	@param filterFn - 필터 함수.
	@return - 필터링된 테이블.
]=]
function TableUtil.filter<K, V>(tbl: { [K]: V }, filterFn: (value: V, key: K) -> boolean): { [K]: V }
	local ret = {} :: { [K]: V }
	for key, value in pairs(tbl) do
		if filterFn(value, key) then
			ret[key] = value
		end
	end
	return ret
end

--[=[
	모든 값을 변환한 새 테이블을 반환합니다.
	@param tbl - 대상 테이블.
	@param mapFn - 변환 함수.
	@return - 변환된 테이블.
]=]
function TableUtil.map<K, V, R>(tbl: { [K]: V }, mapFn: (value: V, key: K) -> R): { [K]: R }
	local ret = {} :: { [K]: R }
	for key, value in pairs(tbl) do
		ret[key] = mapFn(value, key)
	end
	return ret
end

--[=[
	모든 값이 조건을 통과하는지 검사합니다.
	@param tbl - 점검할 테이블.
	@param testFn - 검사 함수.
	@return - 모두 통과하면 true.
]=]
function TableUtil.every<K, V>(tbl: { [K]: V }, testFn: (value: V, key: K) -> boolean): boolean
	for key, value in pairs(tbl) do
		if testFn(value, key) == false then
			return false
		end
	end
	return true
end

--[=[
	여러 테이블을 앞쪽부터 차례로 병합합니다.

	문자열과 숫자 키가 혼합된 테이블을 지원합니다.
	키가 숫자면 배열로 취급하여 순서대로 삽입합니다.
	키가 문자열이면 딕셔너리로 취급하여 뒤쪽 값으로 덮어씁니다.

	@param ... - 병합할 테이블들.
	@return - 병합된 테이블.
]=]
function TableUtil.merge(...: { [any]: any }): { [any]: any }
	local ret = {} :: { [any]: any }

	for _, t in { ... } do
		for k, v in t do
			if type(k) == "number" then
				insert(ret, v)
			else
				ret[k] = v
			end
		end
	end

	return ret
end

--[=[
	배열을 순서대로 이어 붙인 새 배열을 만듭니다.
	@param ... - 이어 붙일 배열들.
	@return - 병합된 배열.
]=]
function TableUtil.mergeArray<T>(...: { T }): { T }
	local ret = {} :: { T }

	for _, t in { ... } do
		for _, v in t do
			insert(ret, v)
		end
	end

	return ret
end

--[=[
	사전형 테이블을 뒤쪽 값으로 덮어쓰며 병합합니다.
	@param ... - 병합할 딕셔너리.
	@return - 병합된 딕셔너리.
]=]
function TableUtil.mergeDict<K, V>(...: { [K]: V }): { [K]: V }
	local ret = {} :: { [K]: V }

	for _, t in { ... } do
		for k, v in t do
			ret[k] = v
		end
	end

	return ret
end

--[=[
	배열형 테이블의 구간을 동일한 값으로 채웁니다.
	@param tbl - 대상 배열.
	@param value - 채울 값.
	@param start - 시작 위치.
	@param stop - 끝 위치.
	@return - 수정된 배열.
]=]
function TableUtil.fill<T>(tbl: { T }, value: T, start: number?, stop: number?): { T }
	if TableUtil.isEmpty(tbl) then
		error("	bl` must not be empty!", 2)
	elseif TableUtil.isDict(tbl) then
		error("	bl` must be a array-like table!", 2)
	elseif start ~= nil and start <= 0 then
		error("`start` must be more than 0!", 2)
	elseif stop ~= nil and stop > #tbl then
		error("`stop` must not exceed #tbl!", 2)
	end

	for i = start or 1, stop or #tbl do
		tbl[i] = value
	end

	return tbl
end

--[=[
	배열에서 중복 값을 제거하고 순서를 유지합니다.
	@param tbl - 대상 배열.
	@return - 중복이 제거된 배열.
]=]
function TableUtil.removeDupes<T>(tbl: { T }): { T }
	if TableUtil.isEmpty(tbl) then
		error("	bl` must not be empty!", 2)
	elseif TableUtil.isDict(tbl) then
		error("	bl` must be a array-like table!", 2)
	end

	local hash = {} :: { [any]: boolean }
	local ret = {} :: { T }
	for _, v in ipairs(tbl) do
		if not hash[v] then
			insert(ret, v)
			hash[v] = true
		end
	end

	return ret
end

--[=[
	테이블과 모든 하위 테이블을 재귀적으로 freeze 합니다.

	@param tbl - 동결할 테이블.
	@return - 동결된 원본 테이블.
]=]
function TableUtil.deepFreeze(tbl: { [any]: any }): { [any]: any }
	table.freeze(tbl)

	for _, v in pairs(tbl) do
		if typeof(v) == "table" then
			TableUtil.deepFreeze(v)
		end
	end

	return tbl
end

local function isEqual(x: any, y: any): boolean
	return x == y and (x ~= 0 or 1 / x == 1 / y) or x ~= x and y ~= y
end

--[=[
	두 테이블의 얕은 동등성을 비교합니다.

	@param tbl1 - 비교 대상.
	@param tbl2 - 비교 대상.
	@return - 모든 키와 값이 같으면 true.
]=]
function TableUtil.shallowEqual(tbl1: { [any]: any }, tbl2: { [any]: any }): boolean
	for key, value in tbl1 do
		if not isEqual(tbl2[key], value) then
			return false
		end
	end

	for key, value in tbl2 do
		if not isEqual(tbl1[key], value) then
			return false
		end
	end

	return true
end

local function defaultComparator(a, b): boolean
	return a < b
end

--[=[
	정렬된 배열에서 대상 값을 이진 탐색합니다.

	@param array - 정렬된 배열.
	@param target - 찾을 값.
	@param comparator - 정렬 비교 함수.
	@return - 찾은 위치 인덱스.
]=]
function TableUtil.binarySearch<item>(array: { item }, target: item, comparator: ((a: item, b: item) -> boolean)?): number?
	comparator = comparator or defaultComparator
	local low, high = 1, #array
	while low <= high do
		local mid = (low + high) // 2
		if comparator(target, array[mid]) then
			high = mid - 1
		elseif comparator(array[mid], target) then
			low = mid + 1
		else
			return mid -- Found target
		end
	end
	return nil -- Not found
end

--[=[
	정렬된 배열에서 대상이 들어갈 가장 왼쪽 위치를 반환합니다.

	@param array - 정렬된 배열.
	@param target - 삽입 값.
	@param comparator - 정렬 비교 함수.
	@return - 삽입 지점 인덱스.
]=]
function TableUtil.bisectLeft<item>(array: { item }, target: item, comparator: ((a: item, b: item) -> boolean)?): number
	comparator = comparator or defaultComparator
	local low, high = 1, #array + 1
	while low < high do
		local mid = (low + high) // 2
		if not comparator(array[mid], target) then -- arr[mid] >= target
			high = mid
		else
			low = mid + 1
		end
	end
	return low
end

--[=[
	정렬된 배열에서 대상이 들어갈 가장 오른쪽 위치를 반환합니다.
	@param array - 정렬된 배열.
	@param target - 삽입 값.
	@param comparator - 정렬 비교 함수.
	@return - 삽입 지점 인덱스.
]=]
function TableUtil.bisectRight<item>(array: { item }, target: item, comparator: ((a: item, b: item) -> boolean)?): number
	comparator = comparator or defaultComparator
	local low, high = 1, #array + 1
	while low < high do
		local mid = (low + high) // 2
		if comparator(target, array[mid]) then -- target < arr[mid]
			high = mid
		else
			low = mid + 1
		end
	end
	return low
end

table.freeze(TableUtil)

return TableUtil
