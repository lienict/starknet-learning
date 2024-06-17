use starknet::ContractAddress;

#[starknet::interface]
pub trait IOwnerable<TContractState> {
    fn owner(self: @TContractState) -> ContractAddress;
    fn transfer_ownership(ref self: TContractState, new: ContractAddress);
    fn renounce_ownership(ref self: TContractState);
}

pub mod Errors {
    pub const UNAUTHORIZED: felt252 = 'Not Owner';
    pub const ZERO_ADDRESS_OWNER: felt252 = 'Owner cannot be zero';
    pub const ZERO_ADDRESS_CALLER: felt252 = 'Caller cannot be zero';
}

#[starknet::component]
pub mod ownable_component {
    use starknet::{ContractAddress, get_caller_address};
    use core::num::traits::Zero;
    use super::Errors;

    #[storage]
    struct Storage {
        owneable_owner: ContractAddress
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {}

    #[embeddable_as(Ownable)]
    pub impl OwnableImpl<
        TContractState, +HasComponent<TContractState>
    > of super::IOwnerable<ComponentState<TContractState>> {
        fn owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owneable_owner.read()
        }
        fn transfer_ownership(ref self: ComponentState<TContractState>, new: ContractAddress) {
            self._assert_only_owner();
            self._transfer_ownership(new);
        }
        fn renounce_ownership(ref self: ComponentState<TContractState>) {
            self._assert_only_owner();
            self._renounce_ownership();
        }
    }

    #[generate_trait]
    pub impl OwnableInternalImpl<
        TContractState, +HasComponent<TContractState>
    > of OwnableInternalTrait<TContractState> {
        fn _assert_only_owner(self: @ComponentState<TContractState>) {
            let caller = get_caller_address();
            assert(caller.is_non_zero(), Errors::ZERO_ADDRESS_CALLER);
            assert(caller == self.owneable_owner.read(), Errors::ZERO_ADDRESS_OWNER);
        }

        fn _init(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            assert(owner.is_non_zero(), Errors::ZERO_ADDRESS_CALLER);
            self.owneable_owner.write(owner);
        }

        fn _transfer_ownership(ref self: ComponentState<TContractState>, new: ContractAddress) {
            assert(new.is_non_zero(), Errors::ZERO_ADDRESS_CALLER);
            self.owneable_owner.write(new);
        }

        fn _renounce_ownership(ref self: ComponentState<TContractState>) {
            // let previous = self.owneable_owner.read();
            self.owneable_owner.write(Zero::zero());
        }
    }
}
