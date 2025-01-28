module pkg2::r3;

use sui::object::{Self, UID};
use sui::table::{Self, Table};
use sui::tx_context::TxContext;
use sui::transfer;
use sui::event;

// Error codes
const EItemNotFound: u64 = 0;
const EInvalidRange: u64 = 1;

/// ManagedList structure
public struct ManagedList<T: store + copy + drop> has key {
    id: UID,
    items: vector<T>,
    item_to_index_map: Table<T, u64>  // Table stores values directly
}

/// Event structure for tracking changes
public struct ListUpdatedEvent<T: store + copy + drop> has copy, drop {
    item: T,
    is_added: bool
}

/// Initialize new list with owner
public fun new<T: store + copy + drop>(
    ctx: &mut TxContext
): ManagedList<T> {
    ManagedList<T> {
        id: object::new(ctx),
        items: vector::empty(),
        item_to_index_map: table::new(ctx)
    }
}

/// Share the list to make it publicly accessible
public fun share_list<T: store + copy + drop>(
    list: ManagedList<T>
) {
    transfer::share_object(list)
}

/// Internal add implementation 
fun add_internal<T: store + copy + drop>(
    list: &mut ManagedList<T>,
    item: T
) {
    if (!table::contains(&list.item_to_index_map, item)) {
        let index = vector::length(&list.items);
        vector::push_back(&mut list.items, item);
        table::add(&mut list.item_to_index_map, item, index);
        event::emit(ListUpdatedEvent { item, is_added: true });
    }
}

/// Internal remove implementation with value operations
    fun remove_internal<T: store + copy + drop>(
        list: &mut ManagedList<T>,
        item: T
    ) {
        if (table::contains(&list.item_to_index_map, item)) {
            let index = *table::borrow(&list.item_to_index_map, item);
            let last_index = vector::length(&list.items) - 1;
            let last_item = vector::swap_remove(&mut list.items, index);
            
            if (index != last_index) {
                table::remove(&mut list.item_to_index_map, last_item);
                table::add(&mut list.item_to_index_map, last_item, index);
            };
            
            table::remove(&mut list.item_to_index_map, item);
            event::emit(ListUpdatedEvent { item, is_added: false });
        }
    }