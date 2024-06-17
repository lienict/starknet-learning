// interface definded entrypoints
// component doesn't have constructor function. we can create _init function to call
#[starknet::interface]
trait ISwitchable<TContractState> {
    fn is_on(self: @TContractState) -> bool;
    fn switch(ref self: TContractState);
}

#[starknet::component]
pub mod switchable_component {
    #[storage]
    struct Storage {
        switchable_value: bool
    }

    #[derive(Drop, starknet::Event)]
    struct SwitchEvent {}

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        SwitchEvent: SwitchEvent,
    }


    #[embeddable_as(Switchable)]
    impl SwitchableImpl<
        TContractState, +HasComponent<TContractState>
    > of super::ISwitchable<ComponentState<TContractState>> {
        fn is_on(self: @ComponentState<TContractState>) -> bool {
            self.switchable_value.read()
        }
        fn switch(ref self: ComponentState<TContractState>) {
            self.switchable_value.write(!self.switchable_value.read());
        }
    }

    #[generate_trait]
    pub impl SwitchableInternalImpl<
        TContractState, +HasComponent<TContractState>
    > of SwitchableInternalTrait<TContractState> {
        fn _off(ref self: ComponentState<TContractState>) {
            self.switchable_value.write(false);
        }
    }
}
