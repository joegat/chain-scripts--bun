
#[test_only]
module pkg2::r2_tests {
    use sui::test_scenario;
    use sui::tx_context;
    use pkg2::managed_list;

    const EItemExists: u64 = 100;
    const EItemNotFound: u64 = 101;
    const ENotOwner: u64 = 102;

    #[test]
    fun test_list_lifecycle() {
        let mut scenario = test_scenario::begin(@0x0);
        let ctx = test_scenario::ctx(&mut scenario);
        
        // Initialize
        let list = managed_list::new(ctx);
        managed_list::share_list(list);
        assert!(managed_list::length(&list) == 0, 0);

        // Add single
        test_scenario::next_tx(&mut scenario, @0x1);
        managed_list::add(&mut list, @0x1, ctx);
        assert!(managed_list::contains(&list, @0x1), 1);
        assert!(managed_list::length(&list) == 1, 2);

        // Batch add
        test_scenario::next_tx(&mut scenario, @0x1);
        managed_list::batch_add(&mut list, vector[@0x2, @0x3], ctx);
        assert!(managed_list::length(&list) == 3, 3);
        assert!(managed_list::contains(&list, @0x2), 4);
        assert!(managed_list::contains(&list, @0x3), 5);

        // Pagination
        let page = managed_list::get_range(&list, 1, 3);
        assert!(vector::length(&page) == 2, 6);
        assert!(*vector::borrow(&page, 0) == @0x2, 7);
        assert!(*vector::borrow(&page, 1) == @0x3, 8);

        // Remove single
        test_scenario::next_tx(&mut scenario, @0x1);
        managed_list::remove(&mut list, @0x2, ctx);
        assert!(!managed_list::contains(&list, @0x2), 9);
        assert!(managed_list::length(&list) == 2, 10);

        // Batch remove
        test_scenario::next_tx(&mut scenario, @0x1);
        managed_list::batch_remove(&mut list, vector[@0x1, @0x3], ctx);
        assert!(managed_list::length(&list) == 0, 11);

        test_scenario::end(scenario);
    }

    #[test]
    fun test_duplicate_operations() {
        let mut scenario = test_scenario::begin(@0x0);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let list = managed_list::new(ctx);
        managed_list::share_list(list);

        // Add duplicate
        test_scenario::next_tx(&mut scenario, @0x1);
        managed_list::add(&mut list, @0x1, ctx);
        managed_list::add(&mut list, @0x1, ctx); // Should be no-op
        assert!(managed_list::length(&list) == 1, 0);

        // Remove non-existent
        test_scenario::next_tx(&mut scenario, @0x1);
        managed_list::remove(&mut list, @0x9, ctx); // Should be no-op
        assert!(managed_list::length(&list) == 1, 1);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ENotOwner)]
    fun test_unauthorized_access() {
        let mut scenario = test_scenario::begin(@0x0);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let list = managed_list::new(ctx);
        managed_list::share_list(list);

        // Non-owner try to add
        test_scenario::next_tx(&mut scenario, @0x1);
        managed_list::add(&mut list, @0x9, ctx);

        test_scenario::end(scenario);
    }



   #[test]
#[expected_failure(abort_code = EInvalidRange)]
fun test_invalid_pagination() {
    use sui::test_scenario;
    
    let mut scenario = test_scenario::begin(@0x0);
    let ctx = test_scenario::ctx(&mut scenario);
    
    // Explicitly specify type parameter
    let list = managed_list::new<u64>(ctx); // <-- Add type annotation
    managed_list::share_list(list);

    // Should fail - now with known type
    let _ = managed_list::get_range(&list, 1, 0);

    test_scenario::end(scenario);
}

    #[test]
    fun test_ownership_transfer() {
        let mut scenario = test_scenario::begin(@0x0);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let list = managed_list::new(ctx);
        managed_list::share_list(list);

        // Transfer ownership
        test_scenario::next_tx(&mut scenario, @0x0);
        let new_owner = @0x9;
        list.owner = new_owner;

        // New owner operations
        test_scenario::next_tx(&mut scenario, new_owner);
        let new_ctx = test_scenario::ctx(&mut scenario);
        managed_list::add(&mut list, @0x1, new_ctx);
        assert!(managed_list::contains(&list, @0x1), 0);

        test_scenario::end(scenario);
    }

    #[test]
    fun test_large_batch_operations() {
        let mut scenario = test_scenario::begin(@0x0);
        let ctx = test_scenario::ctx(&mut scenario);
        
        let list = managed_list::new(ctx);
        managed_list::share_list(list);

        // Generate 100 items
        let mut items = vector[];
        let i = 0;
        while (i < 100) {
            vector::push_back(&mut items, @i);
            i = i + 1;
        };

        test_scenario::next_tx(&mut scenario, @0x0);
        managed_list::batch_add(&mut list, items, ctx);
        assert!(managed_list::length(&list) == 100, 0);

        // Verify pagination
        let page1 = managed_list::get_range(&list, 0, 10);
        assert!(vector::length(&page1) == 10, 1);
        
        let page2 = managed_list::get_range(&list, 90, 100);
        assert!(*vector::borrow(&page2, 0) == @90, 2);

        test_scenario::end(scenario);
    }
}