object "Token" {
    code {
        /* -------- STORAGE LAYOUT ---------- */
        function ownerPos() -> p { p := 0 }
        function totalSupplyPos() -> p { p := 1 }
        function namePos() -> p { p := 2 }
        function symbolPos() -> p { p := 3 }
        function decimalsPos() -> p { p := 4 }
        function capPos() -> p { p := 5 }

        /* -------- HELPERS -------- */

        function round_up_to_mul_of_32(value) -> result {
            result := and(add(value, 31), not(31))
        }

        function allocate_memory(size) -> memPtr {
            memPtr := mload(64)
            let newFreePtr := add(memPtr, round_up_to_mul_of_32(size))
            mstore(64, newFreePtr)
        }

        function abi_decode_string(headStart, headEnd) -> array_ptr {
            let offset := add(headStart, mload(add(headStart, 0)))
            let length := mload(offset)
            // add length slot
            let size := round_up_to_mul_of_32(length)
            let array_alloc_size := add(size, 0x20)
            array_ptr := allocate_memory(array_alloc_size)
            mstore(array_ptr, length)
            let src := add(offset, 0x20)
            let dst := add(array_ptr, 0x20)
            mcopy(dst, src, length)
            mstore(add(dst, length), 0)
        }

        function extract_string_arg_to_memory() -> ptr {
            let programSize := datasize("Token")
            let argSize := sub(codesize(), programSize)

            let memoryDataOffset := allocate_memory(argSize)
            codecopy(memoryDataOffset, programSize, argSize)
            ptr := abi_decode_string(memoryDataOffset, add(memoryDataOffset, argSize))
        }

        function extract_byte_array_length(data) -> length {
            length := div(data, 2)
            let outOfPlaceEncoding := and(data, 1)
            if iszero(outOfPlaceEncoding) {
                length := and(length, 0x7f)
            }
        }

        function compute_array_data_storage_slot(ptr) -> slot {
            slot := ptr
            mstore(0, ptr)
            slot := keccak256(0, 0x20)
        }

        function mask_bytes_dynamic(data, bytes) -> result {
            let mask := not(shr(mul(8, bytes), not(0)))
            result := and(data, mask)
        }

        function extract_used_part_and_set_length_of_short_byte_array(data, len) -> used {
            // we want to save only elements that are part of the array after resizing
            // others should be set to zero
            data := mask_bytes_dynamic(data, len)
            used := or(data, mul(2, len))
        }

        function store_string(slot, src) {
            let newLen := mload(src)
            let oldLen := extract_byte_array_length(sload(slot))

            let srcOffset := 0x20

            switch gt(newLen, 31)
            // store long string to multiple slots
            case 1 {
                let loopEnd := and(newLen, not(0x1f))

                let dstPtr := compute_array_data_storage_slot(slot)
                let i := 0
                for { } lt(i, loopEnd) { i := add(i, 0x20) } {
                    sstore(dstPtr, mload(add(src, srcOffset)))
                    dstPtr := add(dstPtr, 1)
                    srcOffset := add(srcOffset, 32)
                }
                if lt(loopEnd, newLen) {
                    let lastValue := mload(add(src, srcOffset))
                    sstore(dstPtr, mask_bytes_dynamic(lastValue, and(newLen, 0x1f)))
                }
                sstore(slot, add(mul(newLen, 2), 1))
            }
            // store short string to one slot
            default {
                let value := 0
                if newLen {
                    value := mload(add(src, srcOffset))
                }
                sstore(slot, extract_used_part_and_set_length_of_short_byte_array(value, newLen))
            }
        }

        /* -------- CONSTRUCTOR -------- */

        mstore(64, memoryguard(128))

        // Store the creator in its slot
        sstore(ownerPos(), caller())

        // Decode and Store CAP
        /*
        let programSize := datasize("Token")
        let argSize := sub(codesize(), programSize)

        let memoryDataOffset := mload(64)
        codecopy(memoryDataOffset, programSize, argSize)
        let cap := mload(memoryDataOffset)

        sstore(capPos(), cap)
        */

        let name_ptr := extract_string_arg_to_memory()
        store_string(namePos(), name_ptr)

        // Deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }
    object "runtime" {
        code {
            mstore(64, memoryguard(128))

            // Protection against sending Ether
            require(iszero(callvalue()))

            // Dispatcher
            switch selector()
            case 0x06fdde03 /* "name()" */ {
                returnString(name())
            }
            case 0x95d89b41 /* "symbol()" */ {

            }
            case 0x313ce567 /* "decimals()" */ {

            }
            case 0x355274ea /* "cap()" */ {
                returnUint(cap())
            }
            case 0x18160ddd /* "totalSupply()" */ {
                returnUint(totalSupply())
            }
            case 0x70a08231 /* "balanceOf(address)" */ {
                returnUint(balanceOf(decodeAsAddress(0)))
            }
            case 0xa9059cbb /* "transfer(address,uint256)" */ {
                transfer(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            case 0x23b872dd /* "transferFrom(address,address,uint256)" */ {
                transferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2))
                returnTrue()
            }
            case 0x095ea7b3 /* "approve(address,uint256)" */ {
                approve(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            case 0xdd62ed3e /* "allowance(address,address)" */ {
                returnUint(allowance(decodeAsAddress(0), decodeAsAddress(1)))
            }
            case 0x40c10f19 /* "mint(address,uint256)" */ {
                mint(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            default {
                revert(0, 0)
            }

            function mint(account, amount) {
                require(calledByOwner())

                mintTokens(amount)
                addToBalance(account, amount)
                emitTransfer(0, account, amount)
            }
            function transfer(to, amount) {
                executeTransfer(caller(), to, amount)
            }
            function approve(spender, amount) {
                revertIfZeroAddress(spender)
                setAllowance(caller(), spender, amount)
                emitApproval(caller(), spender, amount)
            }
            function transferFrom(from, to, amount) {
                decreaseAllowanceBy(from, caller(), amount)
                executeTransfer(from, to, amount)
            }

            function executeTransfer(from, to, amount) {
                revertIfZeroAddress(to)
                deductFromBalance(from, amount)
                addToBalance(to, amount)
                emitTransfer(from, to, amount)
            }


            /* ---------- calldata decoding functions ----------- */
            function selector() -> s {
                s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
            }

            function decodeAsAddress(offset) -> v {
                v := decodeAsUint(offset)
                if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }
            function decodeAsUint(offset) -> v {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                v := calldataload(pos)
            }
            /* ---------- calldata encoding functions ---------- */
            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }
            function returnTrue() {
                returnUint(1)
            }
            function returnString(s) {
                let memPos := allocate_unbounded()
                let memEnd := add(memPos, 32)
                mstore(add(memPos, 0), sub(memEnd, memPos))

                let length := mload(s)
                mstore(memEnd, length)
                memEnd := add(memEnd, 0x20)

                mcopy(memEnd, add(s, 0x20), length)
                mstore(add(memEnd, length), 0)

                memEnd := add(memEnd, round_up_to_mul_of_32(length))

                return(memPos, sub(memEnd, memPos))
            }

            /* -------- events ---------- */
            function emitTransfer(from, to, amount) {
                let signatureHash := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
                emitEvent(signatureHash, from, to, amount)
            }
            function emitApproval(from, spender, amount) {
                let signatureHash := 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
                emitEvent(signatureHash, from, spender, amount)
            }
            function emitEvent(signatureHash, indexed1, indexed2, nonIndexed) {
                mstore(0, nonIndexed)
                log3(0, 0x20, signatureHash, indexed1, indexed2)
            }

            /* -------- memory operations ---------- */
            function round_up_to_mul_of_32(value) -> result {
                result := and(add(value, 31), not(31))
            }

            function allocate_unbounded() -> memPtr {
                memPtr := mload(64)
            }

            function finalize_allocation(memPtr, size) {
                let newFreePtr := add(memPtr, round_up_to_mul_of_32(size))
                mstore(64, newFreePtr)
            }

            function array_store_length_for_encoding(pos, length) -> updated_pos {
                mstore(pos, length)
                updated_pos := add(pos, 0x20)
            }


            /* -------- storage layout ---------- */
            function ownerPos() -> p { p := 0 }
            function totalSupplyPos() -> p { p := 1 }
            function namePos() -> p { p := 2 }
            function symbolPos() -> p { p := 3 }
            function decimalsPos() -> p { p := 4 }
            function capPos() -> p { p := 5 }
            function accountToStorageOffset(account) -> offset {
                offset := add(0x1000, account)
            }
            function allowanceStorageOffset(account, spender) -> offset {
                offset := accountToStorageOffset(account)
                mstore(0, offset)
                mstore(0x20, spender)
                offset := keccak256(0, 0x40)
            }

            /* -------- storage access ---------- */
            function extract_byte_array_length(data) -> length {
                length := div(data, 2)
                let outOfPlaceEncoding := and(data, 1)
                if iszero(outOfPlaceEncoding) {
                    length := and(length, 0x7f)
                }
            }

            function array_data_slot(ptr) -> data {
                data := ptr
                mstore(0, ptr)
                data := keccak256(0, 0x20)
            }

            function read_string_from_storage(slot) -> memPtr {
                memPtr := allocate_unbounded()

                let end := 0
                let slotValue := sload(slot)
                let length := extract_byte_array_length(slotValue)
                let str_part_ptr := array_store_length_for_encoding(memPtr, length)
                switch and(slotValue, 1)
                case 0 {
                    // short byte array
                    mstore(str_part_ptr, and(slotValue, not(0xff)))
                    end := add(str_part_ptr, mul(0x20, iszero(iszero(length))))
                }
                case 1 {
                    // long byte array
                    let dataPos := array_data_slot(slot)
                    let i := 0
                    for { } lt(i, length) { i := add(i, 0x20) } {
                        mstore(add(str_part_ptr, i), sload(dataPos))
                        dataPos := add(dataPos, 1)
                    }
                    end := add(str_part_ptr, i)
                }

                finalize_allocation(memPtr, sub(end, memPtr))
            }

            function owner() -> o {
                o := sload(ownerPos())
            }
            function name() -> n {
                n := read_string_from_storage(namePos())
            }
            function symbol() -> s {
                s := sload(symbolPos())
            }
            function decimals() -> d {
                d := sload(decimalsPos())
            }
            function totalSupply() -> supply {
                supply := sload(totalSupplyPos())
            }
            function cap() -> c {
                c := sload(capPos())
            }
            function mintTokens(amount) {
                sstore(totalSupplyPos(), safeAdd(totalSupply(), amount))
            }
            function balanceOf(account) -> bal {
                bal := sload(accountToStorageOffset(account))
            }
            function addToBalance(account, amount) {
                let offset := accountToStorageOffset(account)
                sstore(offset, safeAdd(sload(offset), amount))
            }
            function deductFromBalance(account, amount) {
                let offset := accountToStorageOffset(account)
                let bal := sload(offset)
                require(lte(amount, bal))
                sstore(offset, sub(bal, amount))
            }
            function allowance(account, spender) -> amount {
                amount := sload(allowanceStorageOffset(account, spender))
            }
            function setAllowance(account, spender, amount) {
                sstore(allowanceStorageOffset(account, spender), amount)
            }
            function decreaseAllowanceBy(account, spender, amount) {
                let offset := allowanceStorageOffset(account, spender)
                let currentAllowance := sload(offset)
                require(lte(amount, currentAllowance))
                sstore(offset, sub(currentAllowance, amount))
            }

            /* ---------- utility functions ---------- */
            function lte(a, b) -> r {
                r := iszero(gt(a, b))
            }
            function gte(a, b) -> r {
                r := iszero(lt(a, b))
            }
            function safeAdd(a, b) -> r {
                r := add(a, b)
                if or(lt(r, a), lt(r, b)) { revert(0, 0) }
            }
            function calledByOwner() -> cbo {
                cbo := eq(owner(), caller())
            }
            function revertIfZeroAddress(addr) {
                require(addr)
            }
            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }
        }
    }
}
