module pkg2::r1;

use sui::table::{Self as table, Table};
use sui::object::{UID, Self as object};
use sui::transfer;
use sui::tx_context::TxContext;

const ENotAuthorized: u64 = 0;
const ENotWhitelisted: u64 = 1;

public struct Whitelist has key {
    id: UID,
    admin: address,
    val: u64,
    whitelisteds: Table<address, bool>,
}

fun init(ctx: &mut TxContext) {
    let whitelist = Whitelist {
        id: object::new(ctx),
        admin: ctx.sender(),
        val: 0,
        whitelisteds: table::new(ctx)
    };
    transfer::share_object(whitelist);
}

fun assert_admin(self: &Whitelist, ctx: &TxContext) {
    assert!(ctx.sender() == self.admin, ENotAuthorized);
}

public(package) fun is_whitelisted(self: &Whitelist, addr: address): bool {
    table::contains(&self.whitelisteds, addr)
}

public entry fun add_whitelisteds(
    self: &mut Whitelist,
    addrs: vector<address>,
    ctx: &TxContext
) {
    assert_admin(self, ctx);
    let len = vector::length(&addrs);
    let mut i = 0;
    while (i < len) {
        let addr = vector::borrow(&addrs, i);
        if (!table::contains(&self.whitelisteds, *addr)) {
            table::add(&mut self.whitelisteds, *addr, true);
        };
        i = i + 1;
    };
}

public entry fun remove_whitelisteds(
    self: &mut Whitelist,
    addrs: vector<address>,
    ctx: &TxContext
) {
    assert_admin(self, ctx);
    let len = vector::length(&addrs);
    let mut i = 0;
    while (i < len) {
        let addr = vector::borrow(&addrs, i);
        if (table::contains(&self.whitelisteds, *addr)) {
            table::remove(&mut self.whitelisteds, *addr);
        };
        i = i + 1;
    };
}

public entry fun increment_val(
    self: &mut Whitelist,
    ctx: &TxContext
) {
    assert!(is_whitelisted(self, ctx.sender()), ENotWhitelisted);
    self.val = self.val + 1;

}