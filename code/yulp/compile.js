import Yulp from "yulp";
import { fileURLToPath } from "url";
import { dirname } from "path";
import fs from "fs";

const dirPath = dirname(fileURLToPath(import.meta.url));

let sourceCode;

try {
  sourceCode = fs.readFileSync(dirPath + "/ERC20.yulp", "utf8");
} catch (e) {
  console.error("Error reading file: ", e);
}

const source = Yulp.compile(sourceCode);
fs.writeFileSync(dirPath + "/../compiled/yulp/ir_ERC20.yul", Yulp.print(source.results));
