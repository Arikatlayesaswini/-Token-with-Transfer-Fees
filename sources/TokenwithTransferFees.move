module yassu_addr::FeeToken {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

   
    struct FeeTokenSystem has store, key {
        treasury_balance: u64,   
        fee_percentage: u64,      
        treasury_address: address, 
    }

    
    const E_INSUFFICIENT_BALANCE: u64 = 1;
    const E_INVALID_FEE_PERCENTAGE: u64 = 2;
    const E_SYSTEM_NOT_INITIALIZED: u64 = 3;

 
    public fun initialize_fee_system(
        
        admin: &signer, 
        fee_percentage: u64, 
        treasury_address: address
    ) {
        assert!(fee_percentage <= 100, E_INVALID_FEE_PERCENTAGE);
        
        let fee_system = FeeTokenSystem {
            treasury_balance: 0,
            fee_percentage,
            treasury_address,
        };
        move_to(admin, fee_system);
    }

   
    public fun transfer_with_fee(
        sender: &signer,
        recipient: address,
        amount: u64,
        admin_address: address
    ) acquires FeeTokenSystem {
        assert!(exists<FeeTokenSystem>(admin_address), E_SYSTEM_NOT_INITIALIZED);
        
        let fee_system = borrow_global_mut<FeeTokenSystem>(admin_address);
        
        
        let fee_amount = (amount * fee_system.fee_percentage) / 100;
        let transfer_amount = amount - fee_amount;
        
        
        if (fee_amount > 0) {
            let fee_coins = coin::withdraw<AptosCoin>(sender, fee_amount);
            coin::deposit<AptosCoin>(fee_system.treasury_address, fee_coins);
        };
        
     
        let recipient_coins = coin::withdraw<AptosCoin>(sender, transfer_amount);
        coin::deposit<AptosCoin>(recipient, recipient_coins);
        
        
        fee_system.treasury_balance = fee_system.treasury_balance + fee_amount;
    }

}
