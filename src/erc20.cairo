#[starknet::contract]
pub mod ERC20 {
    use starknet::{ContractAddress};

    mod Errors {
        pub const MINT_TO_ZERO: felt252 = 'ERC20: Mint to 0';
    }

    #[event]
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
    }

    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Transfer {
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub value: felt252,
    }

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u32,
        total_supply: felt252,
        balances: LegacyMap<ContractAddress, felt252>,
        allowances: LegacyMap<(ContractAddress, ContractAddress), felt252>
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        recipient: ContractAddress,
        name: felt252,
        symbol: felt252,
        decimals: u32,
        init_supply: felt252
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);
        self.mint(recipient, init_supply);
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            assert(recipient.is_non_zero(), Errors.MINT_TO_ZERO);
            let supply = self.total_supply.read() + amount;
            self.total_supply.write(supply);
            let balance = self.balances.read(recipient) + amount;
            self.balances.write(recipient, balance);
            self
                .emit(
                    Event::Transfer(
                        Transfer {
                            from: contract_address_const::<0>(), to: recipient, value: amount
                        }
                    )
                );
        }
    }
}
