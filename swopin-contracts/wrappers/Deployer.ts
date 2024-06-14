import { Address, beginCell, Cell, Contract, contractAddress, ContractProvider, Sender, SendMode } from '@ton/core';

export type DeployerConfig = {
    op: number
};

export function deployerConfigToCell(config: DeployerConfig): Cell {
    return beginCell().storeUint(config.op,32).endCell();
}

export class Deployer implements Contract {

    constructor(readonly address: Address, readonly init?: { code: Cell; data: Cell }) {}

    static createFromAddress(address: Address) {
        return new Deployer(address);
    }

    static createFromConfig(config: DeployerConfig, code: Cell, workchain = 0) {
        const data = deployerConfigToCell(config);
        const init = { code, data };
        return new Deployer(contractAddress(workchain, init), init);
    }

    async sendDeploy(provider: ContractProvider, via: Sender, value: bigint) {
        await provider.internal(via, {
            value,
            sendMode: SendMode.PAY_GAS_SEPARATELY,
            body: beginCell().endCell(),
        });
    }
}
