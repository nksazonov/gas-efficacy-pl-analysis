import Yulp from "yulp";
import { fileURLToPath } from "url";
import { dirname } from "path";
import fs from "fs";

const srcPath = process.env.SRC_PATH;
const dirPath = dirname(fileURLToPath(import.meta.url));
const outPath = process.env.OUT_PATH;

let sourceCode;

try {
  sourceCode = fs.readFileSync(dirPath + srcPath, "utf8");
} catch (e) {
  console.error("Error reading file: ", e);
}

const source = Yulp.compile(sourceCode);
fs.writeFileSync(dirPath + outPath, Yulp.print(source.results));
