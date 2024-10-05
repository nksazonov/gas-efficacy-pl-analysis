object "ERC20"   {
  code {
        function safeAdd(x, y) -> z {
          z := add(x, y)
          require(or(eq(z, x), gt(z, x)), 0)
        }
        
        function safeSub(x, y) -> z {
          z := sub(x, y)
          require(or(eq(z, x), lt(z, x)), 0)
        }
        
        function safeMul(x, y) -> z {
          if gt(y, 0) {
            z := mul(x, y)
            require(eq(div(z, y), x), 0)
          }
        }
        
          function safeDiv(x, y) -> z {
            require(gt(y, 0), 0)
            z := div(x, y)
          }
          
function require(arg, message) {
  if lt(arg, 1) {
    mstore(0, message)
    revert(0, 32)
  }
}

function mslice(position, length) -> result {
  result := div(mload(position), exp(2, sub(256, mul(length, 8))))
}


function ConstructorParameters.name_offset(pos) -> res {
  res := mslice(ConstructorParameters.name_offset.position(pos), 32)
}



function ConstructorParameters.name_offset.position(_pos) -> _offset {
  
      
        function ConstructorParameters.name_offset.position._chunk0(pos) -> __r {
          __r := 0x00
        }
      
        function ConstructorParameters.name_offset.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(ConstructorParameters.name_offset.position._chunk0(_pos), add(ConstructorParameters.name_offset.position._chunk1(_pos), 0))
    
}



function ConstructorParameters.symbol_offset(pos) -> res {
  res := mslice(ConstructorParameters.symbol_offset.position(pos), 32)
}



function ConstructorParameters.symbol_offset.position(_pos) -> _offset {
  
      
        function ConstructorParameters.symbol_offset.position._chunk0(pos) -> __r {
          __r := 0x20
        }
      
        function ConstructorParameters.symbol_offset.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(ConstructorParameters.symbol_offset.position._chunk0(_pos), add(ConstructorParameters.symbol_offset.position._chunk1(_pos), 0))
    
}



function ConstructorParameters.decimals(pos) -> res {
  res := mslice(ConstructorParameters.decimals.position(pos), 32)
}



function ConstructorParameters.decimals.position(_pos) -> _offset {
  
      
        function ConstructorParameters.decimals.position._chunk0(pos) -> __r {
          __r := 0x40
        }
      
        function ConstructorParameters.decimals.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(ConstructorParameters.decimals.position._chunk0(_pos), add(ConstructorParameters.decimals.position._chunk1(_pos), 0))
    
}



function ConstructorParameters.cap(pos) -> res {
  res := mslice(ConstructorParameters.cap.position(pos), 32)
}



function ConstructorParameters.cap.position(_pos) -> _offset {
  
      
        function ConstructorParameters.cap.position._chunk0(pos) -> __r {
          __r := 0x60
        }
      
        function ConstructorParameters.cap.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(ConstructorParameters.cap.position._chunk0(_pos), add(ConstructorParameters.cap.position._chunk1(_pos), 0))
    
}



function ConstructorParameters.beneficiary(pos) -> res {
  res := mslice(ConstructorParameters.beneficiary.position(pos), 32)
}



function ConstructorParameters.beneficiary.position(_pos) -> _offset {
  
      
        function ConstructorParameters.beneficiary.position._chunk0(pos) -> __r {
          __r := 0x80
        }
      
        function ConstructorParameters.beneficiary.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(ConstructorParameters.beneficiary.position._chunk0(_pos), add(ConstructorParameters.beneficiary.position._chunk1(_pos), 0))
    
}



function StringLayout.length(pos) -> res {
  res := mslice(StringLayout.length.position(pos), 32)
}



function StringLayout.length.position(_pos) -> _offset {
  
      
        function StringLayout.length.position._chunk0(pos) -> __r {
          __r := 0x00
        }
      
        function StringLayout.length.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(StringLayout.length.position._chunk0(_pos), add(StringLayout.length.position._chunk1(_pos), 0))
    
}



function StringLayout.short_string(pos) -> res {
  res := mslice(StringLayout.short_string.position(pos), 32)
}



function StringLayout.short_string.position(_pos) -> _offset {
  
      
        function StringLayout.short_string.position._chunk0(pos) -> __r {
          __r := 0x20
        }
      
        function StringLayout.short_string.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(StringLayout.short_string.position._chunk0(_pos), add(StringLayout.short_string.position._chunk1(_pos), 0))
    
}


    function round_up_to_mul_of_32(value) -> result {
        result := and(safeAdd(value, 31), not(31))
    }

    function allocate_unbounded() -> _memPtr {
        _memPtr := mload(64)
    }

    function finalize_allocation(_memPtr, size) {
        let newFreePtr := safeAdd(_memPtr, round_up_to_mul_of_32(size))
        mstore(64, newFreePtr)
    }

    function allocate_memory(size) -> _memPtr {
        _memPtr := allocate_unbounded()
        finalize_allocation(_memPtr, size)
    }
  
    // ---------- STORAGE LAYOUT ----------
    

    // ---------- CONSTRUCTOR PARAMETERS ----------
    

    

    /* -------- HELPERS -------- */

    /*
    function round_up_to_mul_of_32(value) -> result {
        result := and(add(value, 31), not(31))
    }
    function allocate_memory(size) -> _memPtr {
        _memPtr := mload(64)
        let newFreePtr := add(_memPtr, round_up_to_mul_of_32(size))
        mstore(64, newFreePtr)
    }
    */

    function array_alloc_size(length) -> size {
        size := round_up_to_mul_of_32(length)
        // add length slot
        size := safeAdd(size, 0x20)
    }
    function abi_decode_string(offset, end) -> array {
        let length := mload(offset)
        array := allocate_memory(array_alloc_size(length))
        mstore(array, length)
        let dst := safeAdd(array, 0x20)
        // copy memory to memory with cleanup
        mcopy(dst, safeAdd(offset, 0x20), length)
        mstore(safeAdd(dst, length), 0)
    }
    function abi_decode_constructor_args(headStart, dataEnd) -> name_ptr, symbol_ptr, decimals, cap, beneficiary {
        name_ptr := abi_decode_string(safeAdd(headStart, ConstructorParameters.name_offset(headStart)), dataEnd)
        symbol_ptr := abi_decode_string(safeAdd(headStart, ConstructorParameters.symbol_offset(headStart)), dataEnd)
        decimals := ConstructorParameters.decimals(headStart)
        cap := ConstructorParameters.cap(headStart)
        beneficiary := ConstructorParameters.beneficiary(headStart)
    }
    function extract_constructor_args() -> name_ptr, symbol_ptr, decimals, cap, beneficiary {
        let programSize := datasize("ERC20")
        let argSize := safeSub(codesize(), programSize)

        let memoryDataOffset := allocate_memory(argSize)
        codecopy(memoryDataOffset, programSize, argSize)
        name_ptr, symbol_ptr, decimals, cap, beneficiary := abi_decode_constructor_args(memoryDataOffset, safeAdd(memoryDataOffset, argSize))
    }
    function compute_array_data_storage_slot(ptr) -> slot {
        slot := ptr
        mstore(0, ptr)
        slot := keccak256(0, 0x20)
    }
    function mask_bytes_dynamic(data, bytes) -> result {
        let mask := not(shr(safeMul(8, bytes), not(0)))
        result := and(data, mask)
    }
    function extract_used_part_and_set_length_of_short_byte_array(_data, len) -> used {
        // we want to save only elements that are part of the array after resizing
        // others should be set to zero
        _data := mask_bytes_dynamic(_data, len)
        used := or(_data, safeMul(2, len))
    }
    function store_string(slot, src) {
        let length := StringLayout.length(src)
        let srcOffset := 0x20

        switch gt(length, 31)
        // store long string to multiple slots
        case 1 {
            let loopEnd := and(length, not(0x1f))

            let dstPtr := compute_array_data_storage_slot(slot)
            let i := 0
            for { } lt(i, loopEnd) { i := safeAdd(i, 0x20) } {
                sstore(dstPtr, mload(safeAdd(src, srcOffset)))
                dstPtr := safeAdd(dstPtr, 1)
                srcOffset := safeAdd(srcOffset, 32)
            }
            if lt(loopEnd, length) {
                let lastValue := mload(safeAdd(src, srcOffset))
                sstore(dstPtr, mask_bytes_dynamic(lastValue, and(length, 0x1f)))
            }
            sstore(slot, safeAdd(safeMul(length, 2), 1))
        }
        // store short string to one slot
        default {
            let value := 0
            if length {
                value := StringLayout.short_string(src)
            }
            sstore(slot, extract_used_part_and_set_length_of_short_byte_array(value, length))
        }
    }

    /* -------- CONSTRUCTOR -------- */
    mstore(64, memoryguard(128))

    let name_ptr, symbol_ptr, decimals, cap, beneficiary := extract_constructor_args()
    store_string(0, name_ptr)
    store_string(1, symbol_ptr)

    sstore(2, decimals)
    sstore(3, cap)

    // set beneficiary balance at cap
    mstore(0, beneficiary) mstore(add(0,32), 4)
    sstore(keccak256(0, 64), cap)

    // Deploy the contract
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime"   {
    code {
  function gte(x, y) -> result {
    if or(gt(x, y), eq(x, y)) {
      result := 0x01
    }
  }
  
  function neq(x, y) -> result {
    result := iszero(eq(x, y))
  }
  
        function safeAdd(x, y) -> z {
          z := add(x, y)
          require(or(eq(z, x), gt(z, x)), 0)
        }
        
        function safeSub(x, y) -> z {
          z := sub(x, y)
          require(or(eq(z, x), lt(z, x)), 0)
        }
        
        function safeMul(x, y) -> z {
          if gt(y, 0) {
            z := mul(x, y)
            require(eq(div(z, y), x), 0)
          }
        }
        
          function safeDiv(x, y) -> z {
            require(gt(y, 0), 0)
            z := div(x, y)
          }
          
function require(arg, message) {
  if lt(arg, 1) {
    mstore(0, message)
    revert(0, 32)
  }
}

function mslice(position, length) -> result {
  result := div(mload(position), exp(2, sub(256, mul(length, 8))))
}

    function round_up_to_mul_of_32(value) -> result {
        result := and(safeAdd(value, 31), not(31))
    }

    function allocate_unbounded() -> _memPtr {
        _memPtr := mload(64)
    }

    function finalize_allocation(_memPtr, size) {
        let newFreePtr := safeAdd(_memPtr, round_up_to_mul_of_32(size))
        mstore(64, newFreePtr)
    }

    function allocate_memory(size) -> _memPtr {
        _memPtr := allocate_unbounded()
        finalize_allocation(_memPtr, size)
    }
  
         // leave first 4 32 byte chunks for hashing, returns etc..

        

        calldatacopy(128, 0, calldatasize()) // copy all calldata to memory

        switch mslice(128, 4) // 4 byte calldata signature

        case 0xa9059cbb {

function transferCalldata.owner(pos) -> res {
  res := mslice(transferCalldata.owner.position(pos), 32)
}



function transferCalldata.owner.position(_pos) -> _offset {
  
      
        function transferCalldata.owner.position._chunk0(pos) -> __r {
          __r := 0x04
        }
      
        function transferCalldata.owner.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(transferCalldata.owner.position._chunk0(_pos), add(transferCalldata.owner.position._chunk1(_pos), 0))
    
}



function transferCalldata.sig.position(_pos) -> _offset {
  
      
        function transferCalldata.sig.position._chunk0(pos) -> __r {
          __r := 0x00
        }
      
        function transferCalldata.sig.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(transferCalldata.sig.position._chunk0(_pos), add(transferCalldata.sig.position._chunk1(_pos), 0))
    
}



function transferCalldata.amount(pos) -> res {
  res := mslice(transferCalldata.amount.position(pos), 32)
}



function transferCalldata.amount.position(_pos) -> _offset {
  
      
        function transferCalldata.amount.position._chunk0(pos) -> __r {
          __r := 0x24
        }
      
        function transferCalldata.amount.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(transferCalldata.amount.position._chunk0(_pos), add(transferCalldata.amount.position._chunk1(_pos), 0))
    
}


            

            executeTransfer(caller(),
                transferCalldata.owner(128),
                transferCalldata.amount(128))
        }

        case 0x23b872dd {

function transferFromCalldata.source(pos) -> res {
  res := mslice(transferFromCalldata.source.position(pos), 32)
}



function transferFromCalldata.source.position(_pos) -> _offset {
  
      
        function transferFromCalldata.source.position._chunk0(pos) -> __r {
          __r := 0x04
        }
      
        function transferFromCalldata.source.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(transferFromCalldata.source.position._chunk0(_pos), add(transferFromCalldata.source.position._chunk1(_pos), 0))
    
}



function transferFromCalldata.sig.position(_pos) -> _offset {
  
      
        function transferFromCalldata.sig.position._chunk0(pos) -> __r {
          __r := 0x00
        }
      
        function transferFromCalldata.sig.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(transferFromCalldata.sig.position._chunk0(_pos), add(transferFromCalldata.sig.position._chunk1(_pos), 0))
    
}



function transferFromCalldata.destination(pos) -> res {
  res := mslice(transferFromCalldata.destination.position(pos), 32)
}



function transferFromCalldata.destination.position(_pos) -> _offset {
  
      
        function transferFromCalldata.destination.position._chunk0(pos) -> __r {
          __r := 0x24
        }
      
        function transferFromCalldata.destination.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(transferFromCalldata.destination.position._chunk0(_pos), add(transferFromCalldata.destination.position._chunk1(_pos), 0))
    
}



function transferFromCalldata.amount(pos) -> res {
  res := mslice(transferFromCalldata.amount.position(pos), 32)
}



function transferFromCalldata.amount.position(_pos) -> _offset {
  
      
        function transferFromCalldata.amount.position._chunk0(pos) -> __r {
          __r := 0x44
        }
      
        function transferFromCalldata.amount.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(transferFromCalldata.amount.position._chunk0(_pos), add(transferFromCalldata.amount.position._chunk1(_pos), 0))
    
}


            

            executeTransfer(transferFromCalldata.source(128),
                transferFromCalldata.destination(128),
                transferFromCalldata.amount(128))
        }

        case 0x095ea7b3 {

function approveCalldata.destination(pos) -> res {
  res := mslice(approveCalldata.destination.position(pos), 32)
}



function approveCalldata.destination.position(_pos) -> _offset {
  
      
        function approveCalldata.destination.position._chunk0(pos) -> __r {
          __r := 0x04
        }
      
        function approveCalldata.destination.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(approveCalldata.destination.position._chunk0(_pos), add(approveCalldata.destination.position._chunk1(_pos), 0))
    
}



function approveCalldata.sig.position(_pos) -> _offset {
  
      
        function approveCalldata.sig.position._chunk0(pos) -> __r {
          __r := 0x00
        }
      
        function approveCalldata.sig.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(approveCalldata.sig.position._chunk0(_pos), add(approveCalldata.sig.position._chunk1(_pos), 0))
    
}



function approveCalldata.amount(pos) -> res {
  res := mslice(approveCalldata.amount.position(pos), 32)
}



function approveCalldata.amount.position(_pos) -> _offset {
  
      
        function approveCalldata.amount.position._chunk0(pos) -> __r {
          __r := 0x24
        }
      
        function approveCalldata.amount.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(approveCalldata.amount.position._chunk0(_pos), add(approveCalldata.amount.position._chunk1(_pos), 0))
    
}


            

            sstore(mappingStorageKey2(caller(),
                approveCalldata.destination(128),
                5), approveCalldata.amount(128))

            mstore(0, approveCalldata.amount(128))
            log3(0, 32,
                0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925,
                caller(),
                approveCalldata.destination(128))

            returnTrue()
        }

        case 0x70a08231 {

function balanceOfCalldata.owner(pos) -> res {
  res := mslice(balanceOfCalldata.owner.position(pos), 32)
}



function balanceOfCalldata.owner.position(_pos) -> _offset {
  
      
        function balanceOfCalldata.owner.position._chunk0(pos) -> __r {
          __r := 0x04
        }
      
        function balanceOfCalldata.owner.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(balanceOfCalldata.owner.position._chunk0(_pos), add(balanceOfCalldata.owner.position._chunk1(_pos), 0))
    
}



function balanceOfCalldata.sig.position(_pos) -> _offset {
  
      
        function balanceOfCalldata.sig.position._chunk0(pos) -> __r {
          __r := 0x00
        }
      
        function balanceOfCalldata.sig.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(balanceOfCalldata.sig.position._chunk0(_pos), add(balanceOfCalldata.sig.position._chunk1(_pos), 0))
    
}


            
            let bal := sload(mappingStorageKey(balanceOfCalldata.owner(128), 4))
            returnUint(bal)
        }

        case 0xdd62ed3e {

function allowanceCalldata.source(pos) -> res {
  res := mslice(allowanceCalldata.source.position(pos), 32)
}



function allowanceCalldata.source.position(_pos) -> _offset {
  
      
        function allowanceCalldata.source.position._chunk0(pos) -> __r {
          __r := 0x04
        }
      
        function allowanceCalldata.source.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(allowanceCalldata.source.position._chunk0(_pos), add(allowanceCalldata.source.position._chunk1(_pos), 0))
    
}



function allowanceCalldata.sig.position(_pos) -> _offset {
  
      
        function allowanceCalldata.sig.position._chunk0(pos) -> __r {
          __r := 0x00
        }
      
        function allowanceCalldata.sig.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(allowanceCalldata.sig.position._chunk0(_pos), add(allowanceCalldata.sig.position._chunk1(_pos), 0))
    
}



function allowanceCalldata.owner(pos) -> res {
  res := mslice(allowanceCalldata.owner.position(pos), 32)
}



function allowanceCalldata.owner.position(_pos) -> _offset {
  
      
        function allowanceCalldata.owner.position._chunk0(pos) -> __r {
          __r := 0x24
        }
      
        function allowanceCalldata.owner.position._chunk1(pos) -> __r {
          __r := pos
        }
      

      _offset := add(allowanceCalldata.owner.position._chunk0(_pos), add(allowanceCalldata.owner.position._chunk1(_pos), 0))
    
}


            
            let allowance := sload(
                mappingStorageKey2(
                    allowanceCalldata.source(128),
                    allowanceCalldata.owner(128),
                    5
                )
            )
            returnUint(allowance)
        }

        // TODO: extract same functions to external object, and inherit it in both ERC20 and Runtime
        case 0x06fdde03 {
            let name := read_string_from_storage(0)
            returnString(name)
        }
        case 0x95d89b41 {
            let symbol := read_string_from_storage(1)
            returnString(symbol)
        }
        case 0x313ce567 {
            let decimals := sload(2)
            returnUint(decimals)
        }
        case 0x18160ddd {
            let totalSupply := sload(3)
            returnUint(totalSupply)
        }

        default { require(0, 0) } // invalid method signature

        stop() // stop execution here..

        function executeTransfer(source, destination, amount) {
            let balanceOfSource := sload(mappingStorageKey(source, 4))
            let allowanceOfDestination := sload(mappingStorageKey2(source, destination, 4))
            let allowanceOfSourceSender := sload(mappingStorageKey2(source, caller(), 5))

            // require(balanceOf[src] >= wad, "Dai/insufficient-balance");
            require(or(gt(balanceOfSource, amount), eq(balanceOfSource, amount)), 0)

            // if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            if and(neq(source, caller()), neq(allowanceOfSourceSender, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)) {
                // require(allowance[src][msg.sender] >= wad, "Dai/insufficient-allowance");
                require(gte(allowanceOfDestination, amount), 0)

                // allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
                sstore(mappingStorageKey2(source, destination, 4),
                    safeSub(allowanceOfDestination, amount))
            }

            //  balanceOf[src] = sub(balanceOf[src], wad);
            sstore(mappingStorageKey(source, 4),
                safeSub(balanceOfSource, amount))

            if iszero(destination) {
              let totalSupply := sload(3)
              sstore(3, safeSub(totalSupply, amount))
            }

            // balanceOf[dst] = add(balanceOf[dst], wad);
            let balanceOfDestination := sload(mappingStorageKey(destination, 4))
            sstore(mappingStorageKey(destination, 4),
                safeAdd(balanceOfDestination, amount))

            mstore(0, amount)
            log3(0, 32, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                source, destination)

            returnTrue()
        }

        /* -------- return operations ---------- */
        function returnUint(v) {
            mstore(0, v)
            return(0, 0x20)
        }

        function returnTrue() {
            returnUint(1)
        }

        function returnString(s) {
            let memPos := allocate_unbounded()
            let memEnd := safeAdd(memPos, 32)
            mstore(safeAdd(memPos, 0), safeSub(memEnd, memPos))

            let length := mload(s)
            mstore(memEnd, length)
            memEnd := safeAdd(memEnd, 0x20)

            mcopy(memEnd, safeAdd(s, 0x20), length)
            mstore(safeAdd(memEnd, length), 0)

            memEnd := safeAdd(memEnd, round_up_to_mul_of_32(length))

            return(memPos, safeSub(memEnd, memPos))
        }

        /* -------- memory operations ---------- */

        /*
        function round_up_to_mul_of_32(value) -> result {
            result := and(add(value, 31), not(31))
        }

        function allocate_unbounded() -> _memPtr {
            _memPtr := mload(64)
        }

        function finalize_allocation(_memPtr, size) {
            let newFreePtr := add(_memPtr, round_up_to_mul_of_32(size))
            mstore(64, newFreePtr)
        }
        */

        function array_store_length_for_encoding(pos, length) -> updated_pos {
            mstore(pos, length)
            updated_pos := safeAdd(pos, 0x20)
        }

        /* -------- storage access ---------- */
        function extract_byte_array_length(_data) -> length {
            length := safeDiv(_data, 2)
            let outOfPlaceEncoding := and(_data, 1)
            if iszero(outOfPlaceEncoding) {
                length := and(length, 0x7f)
            }
        }

        function array_data_slot(ptr) -> _data {
            _data := ptr
            mstore(0, ptr)
            _data := keccak256(0, 0x20)
        }

        function read_string_from_storage(slot) -> _memPtr {
            _memPtr := allocate_unbounded()

            let end := 0
            let slotValue := sload(slot)
            let length := extract_byte_array_length(slotValue)
            let str_part_ptr := array_store_length_for_encoding(_memPtr, length)
            switch and(slotValue, 1)
            case 0 {
                // short byte array
                mstore(str_part_ptr, and(slotValue, not(0xff)))
                end := safeAdd(str_part_ptr, safeMul(0x20, iszero(iszero(length))))
            }
            case 1 {
                // long byte array
                let dataPos := array_data_slot(slot)
                let i := 0
                for { } lt(i, length) { i := safeAdd(i, 0x20) } {
                    mstore(safeAdd(str_part_ptr, i), sload(dataPos))
                    dataPos := safeAdd(dataPos, 1)
                }
                end := safeAdd(str_part_ptr, i)
            }

            finalize_allocation(_memPtr, safeSub(end, _memPtr))
        }

        // Solidity Style Storage Key: mapping(bytes32 => bytes32)
        function mappingStorageKey(key, storageIndex) -> storageKey {
            mstore(0, key) mstore(add(0,32), storageIndex)
            storageKey := keccak256(0, 64)
        }

        // Solidity Style Storage Key: mapping(bytes32 => mapping(bytes32 => bytes32))
        function mappingStorageKey2(key, key2, storageIndex) -> storageKey {
            mstore(0, key) mstore(add(0,32), storageIndex) mstore(add(0,64), key2)
            mstore(96, keccak256(0, 64))
            storageKey := keccak256(64, 64)
        }
    }
  }
}