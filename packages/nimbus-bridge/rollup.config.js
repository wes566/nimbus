import typescript from "rollup-plugin-typescript2";

const iife = {
  plugins: [typescript()],
  input: "src/index.ts",
  output: {
    file: "dist/nimbus.js",
    name: "nimbus",
    format: "iife"
  }
};

export default [iife];
