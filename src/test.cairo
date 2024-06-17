#[starknet::interface]
pub trait ISimpleContract<TContractState> {
    fn get_value(self: @TContractState) -> u32;
    fn get_owner(self: @TContractState) -> starknet::ContractAddress;
    fn set_value(ref self: TContractState, value: u32);
}

#[starknet::contract]
pub mod SimpleContract {
    use starknet::{get_caller_address, ContractAddress};
    #[storage]
    struct Storage {
        value: u32,
        owner: ContractAddress
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_value: u32) {
        self.value.write(init_value);
        self.owner.write(get_caller_address());
    }

    #[abi(embed_v0)]
    impl SimpleContract of super::ISimpleContract<ContractState> {
        fn get_value(self: @ContractState) -> u32 {
            //self.value.read()
            self.get_test()
        }
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
        fn set_value(ref self: ContractState, value: u32) {
            self.value.write(value);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn get_test(self: @ContractState) -> u32 {
            200
        }
    }
}


#[cfg(test)]
mod tests {
    use super::{SimpleContract, ISimpleContractDispatcher, ISimpleContractDispatcherTrait};

    // Import the deploy syscall to be able to deploy the contract.
    use starknet::{SyscallResultTrait, syscalls::deploy_syscall};
    use starknet::{
        ContractAddress, get_caller_address, get_contract_address, contract_address_const
    };

    // Use starknet test utils to fake the contract_address
    use starknet::testing::set_contract_address;

    // Deploy the contract and return its dispatcher.
    fn deploy(initial_value: u32) -> ISimpleContractDispatcher {
        // Declare and deploy
        let (contract_address, _) = deploy_syscall(
            SimpleContract::TEST_CLASS_HASH.try_into().unwrap(),
            0,
            array![initial_value.into()].span(),
            false
        )
            .unwrap_syscall();

        // Return the dispatcher.
        // The dispatcher allows to interact with the contract based on its interface.
        ISimpleContractDispatcher { contract_address }
    }
    #[test]
    fn test_print() {
        println!("hello this is test");
        let init_value: u32 = 10;
        let contract = deploy(init_value);
        println!("contract value: {}", contract.get_value());
    }
}
