module pkg2::managed_list {
    use sui::object::{Self, UID};
    use sui::table::{Self, Table};
    use sui::tx_context::TxContext;
    use sui::transfer;
    use sui::event;
    
    // Error codes
    const EItemNotFound: u64 = 0;
    const ENotOwner: u64 = 1;
    const EInvalidRange: u64 = 2;

    /// ManagedList structure
    public struct ManagedList<T: store + copy + drop> has key {
        id: UID,
        owner: address,
        items: vector<T>,
        indices: Table<T, u64>  // Table stores values directly
    }

    /// Event structure for tracking changes
    public struct ListEvent<T: store + copy + drop> has copy, drop {
        item: T,
        is_added: bool
    }

    /// Initialize new list with owner
    public fun new<T: store + copy + drop>(
        ctx: &mut TxContext
    ): ManagedList<T> {
        ManagedList<T> {
            id: object::new(ctx),
            owner: ctx.sender(),
            items: vector::empty(),
            indices: table::new(ctx)
        }
    }

    /// Share the list to make it publicly accessible
    public fun share_list<T: store + copy + drop>(
        list: ManagedList<T>
    ) {
        transfer::share_object(list)
    }

    /// Internal add implementation with proper value handling
    fun add_internal<T: store + copy + drop>(
        list: &mut ManagedList<T>,
        item: T
    ) {
        if (!table::contains(&list.indices, item)) {
            let index = vector::length(&list.items);
            vector::push_back(&mut list.items, item);
            table::add(&mut list.indices, item, index);
            event::emit(ListEvent { item, is_added: true });
        }
    }

    /// Internal remove implementation with value operations
    fun remove_internal<T: store + copy + drop>(
        list: &mut ManagedList<T>,
        item: T
    ) {
        if (table::contains(&list.indices, item)) {
            let index = *table::borrow(&list.indices, item);
            let last_index = vector::length(&list.items) - 1;
            let last_item = vector::swap_remove(&mut list.items, index);
            
            if (index != last_index) {
                table::remove(&mut list.indices, last_item);
                table::add(&mut list.indices, last_item, index);
            };
            
            table::remove(&mut list.indices, item);
            event::emit(ListEvent { item, is_added: false });
        }
    }

    /// Single item add with auth check
    public entry fun add<T: store + copy + drop>(
        list: &mut ManagedList<T>,
        item: T,
        ctx: &TxContext
    ) {
        assert!(list.owner == ctx.sender(), ENotOwner);
        add_internal(list, item);
    }

    /// Batch add items with proper value handling
    public entry fun batch_add<T: store + copy + drop>(
        list: &mut ManagedList<T>,
        mut items: vector<T>,
        ctx: &TxContext
    ) {
        assert!(list.owner == ctx.sender(), ENotOwner);
        while (!vector::is_empty(&items)) {
            add_internal(list, vector::pop_back(&mut items));
        }
    }

    /// Single item remove with auth check
    public entry fun remove<T: store + copy + drop>(
        list: &mut ManagedList<T>,
        item: T,
        ctx: &TxContext
    ) {
        assert!(list.owner == ctx.sender(), ENotOwner);
        remove_internal(list, item);
    }

    /// Batch remove items with value operations
    public entry fun batch_remove<T: store + copy + drop>(
        list: &mut ManagedList<T>,
        mut items: vector<T>,
        ctx: &TxContext
    ) {
        assert!(list.owner == ctx.sender(), ENotOwner);
        while (!vector::is_empty(&items)) {
            remove_internal(list, vector::pop_back(&mut items));
        }
    }

    /// Check if item exists (corrected value handling)
    public fun contains<T: store + copy + drop>(
        list: &ManagedList<T>,
        item: T
    ): bool {
        table::contains(&list.indices, item)
    }

    /// Paginated item access
    public fun get_range<T: store + copy + drop>(
        list: &ManagedList<T>,
        start: u64,
        end: u64
    ): vector<T> {
        assert!(start <= end, EInvalidRange);
        assert!(end <= vector::length(&list.items), EInvalidRange);
        
        let mut result = vector::empty();
        let mut i = start;
        while (i < end) {
            vector::push_back(&mut result, *vector::borrow(&list.items, i));
            i = i + 1;
        };
        result
    }

    /// Full list access
    public fun get_all<T: store + copy + drop>(
        list: &ManagedList<T>
    ): &vector<T> {
        &list.items
    }

    /// Get total item count
    public fun length<T: store + copy + drop>(
        list: &ManagedList<T>
    ): u64 {
        vector::length(&list.items)
    }
}


/** USAGE

// Create list
let list = managed_list::new<address>(ctx);
managed_list::share_list(list);

// Add items (value passing)
managed_list::add(&mut list, @0x123, ctx);
managed_list::batch_add(&mut list, vector[@0x456, @0x789], ctx);

// Check existence (pass value directly)
assert!(managed_list::contains(&list, @0x123), 0);

// Remove items
managed_list::remove(&mut list, @0x123, ctx);

*/