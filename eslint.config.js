/**
 * Standard ESLint Baseline Configuration (Flat Config)
 *
 * This config is intended for projects that do NOT have their own ESLint setup.
 * For projects with existing ESLint configs, only eslint-config-prettier is needed
 * to avoid Prettier conflicts.
 *
 * Stack:
 *   - @eslint/js recommended              — core JS best practices
 *   - typescript-eslint recommended        — TS type-aware rules
 *   - eslint-plugin-react recommended      — React best practices
 *   - eslint-plugin-react-hooks            — hooks rules-of-hooks + exhaustive-deps
 *   - eslint-plugin-vue recommended        — Vue 3 essential + strongly recommended
 *   - eslint-config-prettier               — disable all formatting rules (Prettier handles those)
 *
 * @see https://eslint.org/docs/latest/use/configure/configuration-files
 */

const js = require('@eslint/js');
const tseslint = require('typescript-eslint');
const pluginReact = require('eslint-plugin-react');
const pluginReactHooks = require('eslint-plugin-react-hooks');
const pluginVue = require('eslint-plugin-vue');
const vueParser = require('vue-eslint-parser');
const prettierConfig = require('eslint-config-prettier');
const globals = require('globals');

module.exports = [
  // ---------------------------------------------------------------------------
  // Global ignores
  // ---------------------------------------------------------------------------
  {
    ignores: [
      'node_modules/**',
      'dist/**',
      'build/**',
      '.next/**',
      '.nuxt/**',
      '.output/**',
      'coverage/**',
      '*.min.js',
    ],
  },

  // ---------------------------------------------------------------------------
  // Base: JavaScript recommended rules
  // ---------------------------------------------------------------------------
  js.configs.recommended,

  // ---------------------------------------------------------------------------
  // TypeScript
  // ---------------------------------------------------------------------------
  ...tseslint.configs.recommended,

  // ---------------------------------------------------------------------------
  // React (JSX / TSX)
  // ---------------------------------------------------------------------------
  {
    files: ['**/*.{jsx,tsx}'],
    plugins: {
      react: pluginReact,
      'react-hooks': pluginReactHooks,
    },
    languageOptions: {
      parserOptions: {
        ecmaFeatures: { jsx: true },
      },
      globals: {
        ...globals.browser,
      },
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
    rules: {
      // React recommended
      ...pluginReact.configs.recommended.rules,
      // React hooks
      ...pluginReactHooks.configs.recommended.rules,

      // --- Relaxed rules (Airbnb-flavored but pragmatic) ---

      // Not needed with React 17+ JSX transform
      'react/react-in-jsx-scope': 'off',

      // Allow prop spreading — useful for HOCs and wrapper components
      'react/jsx-props-no-spreading': 'off',

      // Prefer function declarations for components but don't enforce
      'react/function-component-definition': 'off',

      // TypeScript handles prop types
      'react/prop-types': 'off',

      // Allow index as key in static lists (warn, not error)
      'react/no-array-index-key': 'warn',

      // Encourage self-closing components
      'react/self-closing-comp': 'error',

      // Enforce hooks rules strictly
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
    },
  },

  // ---------------------------------------------------------------------------
  // Vue 3
  // ---------------------------------------------------------------------------
  {
    files: ['**/*.vue'],
    plugins: {
      vue: pluginVue,
    },
    languageOptions: {
      parser: vueParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        parser: tseslint.parser,
        extraFileExtensions: ['.vue'],
      },
      globals: {
        ...globals.browser,
        // Vue 3 compiler macros
        defineProps: 'readonly',
        defineEmits: 'readonly',
        defineExpose: 'readonly',
        withDefaults: 'readonly',
      },
    },
    rules: {
      // Vue 3 essential + strongly recommended rules
      ...pluginVue.configs['vue3-strongly-recommended'].rules,

      // --- Vue Style Guide (Priority A + B) ---

      // Multi-word component names (Priority B)
      'vue/multi-word-component-names': 'warn',

      // Prop name casing — camelCase in script, kebab-case in template
      'vue/prop-name-casing': ['error', 'camelCase'],
      'vue/attribute-hyphenation': ['error', 'always'],

      // Event name casing — kebab-case
      'vue/custom-event-name-casing': ['error', 'kebab-case'],

      // Component name casing — PascalCase in templates
      'vue/component-name-in-template-casing': ['error', 'PascalCase'],

      // Require v-bind shorthand
      'vue/v-bind-style': ['error', 'shorthand'],

      // Require v-on shorthand
      'vue/v-on-style': ['error', 'shorthand'],

      // Require default values for props (except required and Boolean)
      'vue/require-default-prop': 'warn',

      // Enforce defineEmits type-based declaration
      'vue/define-emits-declaration': ['error', 'type-based'],

      // Enforce defineProps type-based declaration
      'vue/define-props-declaration': ['error', 'type-based'],

      // Order of component options — <script setup> is implied
      'vue/block-order': ['error', { order: ['script', 'template', 'style'] }],

      // TypeScript handles this
      'vue/require-prop-types': 'off',
    },
  },

  // ---------------------------------------------------------------------------
  // Node.js files (CommonJS)
  // ---------------------------------------------------------------------------
  {
    files: ['**/*.cjs', '**/.*rc.js', '**/.*rc.cjs'],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
  },

  // ---------------------------------------------------------------------------
  // General JS/TS rules
  // ---------------------------------------------------------------------------
  {
    files: ['**/*.{js,mjs,cjs,ts,mts,jsx,tsx}'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.es2025,
      },
    },
    rules: {
      // --- Best practices ---
      'no-console': 'warn',
      'no-debugger': 'error',
      'no-alert': 'error',
      'no-var': 'error',
      'prefer-const': 'error',
      'prefer-template': 'warn',
      'prefer-arrow-callback': 'warn',
      'no-param-reassign': ['error', { props: false }],
      'no-nested-ternary': 'warn',
      eqeqeq: ['error', 'always', { null: 'ignore' }],
      curly: ['error', 'all'],

      // --- TypeScript-specific relaxations ---
      '@typescript-eslint/no-unused-vars': [
        'error',
        {
          argsIgnorePattern: '^_',
          varsIgnorePattern: '^_',
          destructuredArrayIgnorePattern: '^_',
        },
      ],
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/consistent-type-imports': [
        'warn',
        { prefer: 'type-imports', fixStyle: 'inline-type-imports' },
      ],

      // Disabled — handled by TypeScript compiler
      'no-undef': 'off',
      'no-redeclare': 'off',
      '@typescript-eslint/no-redeclare': 'error',
    },
  },

  // ---------------------------------------------------------------------------
  // Prettier — MUST be last to override all formatting rules
  // ---------------------------------------------------------------------------
  prettierConfig,
];
