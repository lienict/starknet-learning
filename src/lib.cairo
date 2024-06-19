use starknet::ContractAddress;

#[starknet::interface]
pub trait IConstantProductAmm<TContractState> {
    fn swap(ref self: TContractState, token_in: ContractAddress, amount_in: u256) -> u256;
    fn add_liquidity(ref self: TContractState, amount0: u256, amount1: u256) -> u256;
    fn remove_liquidity(ref self: TContractState, shares: u256) -> u256;
}

#[starknet::contract]
mod ConstantProductAmm {
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    #[storage]
    struct Storage {
        token0: IERC20Dispatcher,
        token1: IERC20Dispatcher,
        reserve0: u256,
        reserve1: u256,
        total_supply: u256,
        balance_of: LegacyMap<ContractAddress, u256>,
        fee: u16
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[constructor]
    fn constructor(
        ref self: ContractState, token0: ContractAddress, token1: ContractAddress, fee: u16
    ) {
        self.token0.write(IERC20Dispatcher { contract_address: token0 });
        self.token1.write(IERC20Dispatcher { contract_address: token1 });
        self.fee.write(fee);
    }

    #[abi(embed_v0)]
    impl ConstantProductAmm of super::IConstantProductAmm<ContractState> {
        fn swap(ref self: ContractState, token_in: ContractAddress, amount_in: u256) -> u256 {
            assert(amount_in > 0, 'amount in = 0');
            let (token0, token1): (IERC20Dispatcher, IERC20Dispatcher) = (
                self.token0.read(), self.token1.read()
            );
            let (reserve0, reserve1): (u256, u256) = (self.reserve0.read(), self.reserve1.read());
            let (token0, token1, reserve_in, reserve_out) = (token0, token1, reserve0, reserve1);

            let caller = get_caller_address();
            let this = get_contract_address();

            token0.transfer(caller, this, amount_in);

            let amount_in_with_fee = amount_in * (1000 - self.fee.read().into() / 1000);

            let amount_out = (reserve_out * amount_in_with_fee) / (reserve_in + amount_in_with_fee);
            amount_out
        }
        fn add_liquidity(ref self: ContractState, amount0: u256, amount1: u256) -> u256 {

            let caller = get_caller_address();
            let this = get_contract_address();

            let (token0, token1): (IERC20Dispatcher, IERC20Dispatcher) = (
                self.token0.read(), self.token1.read()
            );

            token0.transfer_from(caller,this,amount0);
            token1.transfer_from(caller,this,amount1);

            // how much dx dy to add
            // dy = y /(x * dx)

            let (reserve0,reserve1): (u256,u256) = (self.reserve0.read(),self.reserve1.read());

        }
        fn remove_liquidity(ref self: ContractState, shares: u256) -> u256 {}
    }
}
