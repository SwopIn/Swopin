import {readFileSync} from "fs";
import {compileFunc, compilerVersion} from '@ton-community/func-js';
import {Cell} from 'ton';


(async () => {
    let version = await compilerVersion();
    
    let result = await compileFunc({
        // Sources
        sources: [
            {
                filename: "imports/stdlib.fc",
                content: readFileSync("contracts/imports/stdlib.fc", "utf8"),
            },
            {
                filename: "imports/op-codes.fc",
                content: readFileSync("contracts/imports/op-codes.fc", "utf8"),
            },
            {
                filename: "nft-fixprice-sale-v3r3.fc",
                content: readFileSync("contracts/nft-fixprice-sale-v3r3.fc", "utf8"),
            },
        ]
    });

    if (result.status === 'error') {
        console.error(result.message)
        return;
    }

    let codeCell = Cell.fromBoc(Buffer.from(result.codeBoc, "base64"))[0];
    
    console.log(result.fiftCode)
    console.log(result.codeBoc)

  })();