mod switchable;


#[starknet::contract]
mod SwitchContract {
    use bonding_curve::switchable::{switchable_component};
    component!(path: switchable_component, storage: switch, event: SwitchableEvent);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        switch: switchable_component::Storage,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        SwitchableEvent :switchable_component::Event
    }

}

