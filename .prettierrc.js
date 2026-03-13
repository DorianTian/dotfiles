/**
 * Prettier Configuration
 *
 * Baseline: Airbnb + Google Style Guide conventions
 * React: Airbnb React Style Guide + Meta conventions
 * Vue: Vue Official Style Guide (Priority A + B) + Element Plus / Ant Design Vue practices
 *
 * @see https://prettier.io/docs/options
 */
module.exports = {
  // ---------------------------------------------------------------------------
  // Global Baseline
  // ---------------------------------------------------------------------------

  /** Enforce semicolons at the end of statements */
  semi: true,

  /** Use single quotes for strings (JSX uses double quotes separately) */
  singleQuote: true,

  /** Trailing commas everywhere — cleaner git diffs */
  trailingComma: 'all',

  /** Max line width — 120 balances readability and screen utilization */
  printWidth: 120,

  /** 2-space indentation — industry standard for JS/TS ecosystem */
  tabWidth: 2,

  /** Use spaces, not tabs */
  useTabs: false,

  /** Always parenthesize arrow function params — consistent and diff-friendly */
  arrowParens: 'always',

  /** Unix line endings — prevent cross-platform issues */
  endOfLine: 'lf',

  /** Spaces inside object braces: { foo: bar } */
  bracketSpacing: true,

  /** Multi-line JSX closing bracket on new line — Airbnb standard */
  bracketSameLine: false,

  /** Preserve markdown prose wrapping — let writers control line breaks */
  proseWrap: 'preserve',

  /** HTML whitespace follows CSS display property — predictable rendering */
  htmlWhitespaceSensitivity: 'css',

  /** Single body-line arrow functions omit braces when possible */
  // Controlled by ESLint, not Prettier — left as default

  // ---------------------------------------------------------------------------
  // JSX / React
  // ---------------------------------------------------------------------------

  /** JSX uses double quotes — Airbnb/Meta convention, consistent with HTML */
  jsxSingleQuote: false,

  // ---------------------------------------------------------------------------
  // Vue
  // ---------------------------------------------------------------------------

  /** Do not indent <script> and <style> block contents — Vue official recommendation */
  vueIndentScriptAndStyle: false,

  // ---------------------------------------------------------------------------
  // Plugins
  // ---------------------------------------------------------------------------
  plugins: ['prettier-plugin-sql'],

  // ---------------------------------------------------------------------------
  // Per-language Overrides
  // ---------------------------------------------------------------------------
  overrides: [
    // --- Vue SFC ---------------------------------------------------------------
    {
      files: '*.vue',
      options: {
        /** Each attribute on its own line — Vue Style Guide (Priority B) */
        singleAttributePerLine: true,
        /** HTML whitespace strict mode for Vue templates */
        htmlWhitespaceSensitivity: 'strict',
      },
    },

    // --- React JSX / TSX -------------------------------------------------------
    {
      files: ['*.jsx', '*.tsx'],
      options: {
        /** Let printWidth decide line breaks — React community convention */
        singleAttributePerLine: false,
        /** JSX double quotes — Airbnb React Style Guide */
        jsxSingleQuote: false,
      },
    },

    // --- JSON -------------------------------------------------------------------
    {
      files: ['*.json', '*.jsonc'],
      options: {
        tabWidth: 2,
        trailingComma: 'none',
      },
    },

    // --- YAML -------------------------------------------------------------------
    {
      files: ['*.yml', '*.yaml'],
      options: {
        tabWidth: 2,
        singleQuote: false,
      },
    },

    // --- Markdown ---------------------------------------------------------------
    {
      files: ['*.md', '*.mdx'],
      options: {
        proseWrap: 'preserve',
        tabWidth: 2,
      },
    },

    // --- CSS / SCSS / Less ------------------------------------------------------
    {
      files: ['*.css', '*.scss', '*.less'],
      options: {
        singleQuote: false,
      },
    },

    // --- HTML -------------------------------------------------------------------
    {
      files: '*.html',
      options: {
        htmlWhitespaceSensitivity: 'css',
        singleAttributePerLine: true,
      },
    },

    // --- SQL (via prettier-plugin-sql) ------------------------------------------
    {
      files: '*.sql',
      options: {
        language: 'sql',
        keywordCase: 'upper',
        dataTypeCase: 'upper',
        functionCase: 'upper',
      },
    },
  ],
};
