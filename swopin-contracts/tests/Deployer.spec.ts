import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Cell, toNano } from '@ton/core';
import { Deployer } from '../wrappers/Deployer';
import '@ton/test-utils';
import { compile } from '@ton/blueprint';

describe('Deployer', () => {
    let code: Cell;

    beforeAll(async () => {
        code = await compile('Deployer');
    });

    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let deployer: SandboxContract<Deployer>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        deployer = blockchain.openContract(Deployer.createFromConfig({}, code));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await deployer.sendDeploy(deployer.getSender(), toNano('0.05'));

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: deployer.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and deployer are ready to use
    });
});
