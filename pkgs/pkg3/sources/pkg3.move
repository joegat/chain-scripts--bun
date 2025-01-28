

// #[allow(duplicate_alias)]
module pkg3::coin; 
use sui::coin::{Self};

public struct COIN has drop {}


fun init(witness: COIN, ctx: &mut TxContext) {
    let (mut treasury_cap, metadata) 
        = coin::create_currency<COIN>(
            witness, 
            9, 
            b"COIN2", 
            b"coin2", 
            b"", 
            option::none(), 
            ctx
        );
    coin::mint_and_transfer(
        &mut treasury_cap, 
        1000_000_000_000_000_000, 
        tx_context::sender(ctx), 
        ctx
    );
    transfer::public_freeze_object(metadata);
    transfer::public_transfer(treasury_cap, tx_context::sender(ctx))
}





// module pkg3::cute; 

// public struct CUTE has drop {}

// fun init(witness: CUTE, ctx: &mut TxContext) {

// }


// module pkg3::pkg3; 

// public struct PKG3 has drop {}

// fun init(witness: PKG3, ctx: &mut TxContext) {

// }

// module pkg3::name; 

// public struct NAME has drop {}

// fun init(witness: NAME, ctx: &mut TxContext) {

// }




