import typescript from "rollup-plugin-typescript2";

export default {
  input: "src/index.ts",
  output: [
    {
      file: "dist/umd/nimbus.js",
      name: "nimbus",
      format: "umd"
    },
    {
      file: "dist/es/nimbus.js",
      format: "es"
    }
  ],
  plugins: [typescript()]
};
