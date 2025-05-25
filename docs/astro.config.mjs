// @ts-check
import { defineConfig, sharpImageService } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLinksValidator from 'starlight-links-validator';
import starlightSidebarTopics from 'starlight-sidebar-topics';
import { remarkHeadingId } from "remark-custom-heading-id";

// https://astro.build/config
export default defineConfig({
  site: "https://togglefy.azeveco.com",
  integrations: [
    starlight({
      tableOfContents: { maxHeadingLevel: 4 },
      editLink: {
        baseUrl: 'https://github.com/azeveco/Togglefy/edit/main/docs/',
      },
      customCss: [
        '@fontsource/montserrat/400.css',
        '@fontsource/montserrat/600.css',
        './src/custom.css'
      ],
      components: {
        ThemeSelect: './src/components/overrides/ThemeSelect.astro',
        Hero: './src/components/overrides/Hero.astro'
      },
      expressiveCode: {
        styleOverrides: { borderRadius: '0.5rem' },
      },
      logo: {
        light: './src/assets/togglefy_horizontal_logo_light_1x.webp',
        dark: './src/assets/togglefy_horizontal_logo_dark_1x.webp',
        replacesTitle: true,
      },
      description: 'Togglefy is a simple yet powerful and flexible library for creating toggleable elements in your web applications. It allows you to easily manage the state of toggles.',
      credits: true,
      title: 'Togglefy',
      lastUpdated: true,
      favicon: 'favicon.svg',
      social: [
        { icon: 'seti:ruby', label: 'RubyGems', href: 'https://rubygems.org/gems/togglefy' },
        { icon: 'github', label: 'GitHub', href: 'https://github.com/azeveco/Togglefy' }
      ],
      plugins: [
        starlightLinksValidator({
          errorOnRelativeLinks: false,
        }),
        starlightSidebarTopics(
          [
            {
              label: 'Documentation',
              link: 'getting-started/',
              id: 'docs',
              icon: 'open-book',
              items: [
                { label: 'Start Here', items: ['getting-started', 'including-it'] },
                {
                  label: 'Usage',
                  items: [
                    { label: 'Managing Features', slug: 'usage/managing-features' },
                    { label: 'Managing Assignables <> Features', slug: 'usage/managing-assignables-features' },
                    { label: 'Querying Features', slug: 'usage/querying-features' },
                    { label: 'Analytics', slug: 'usage/analytics' },
                    { label: 'Aliases', slug: 'usage/aliases' }
                  ]
                },
                // {
                // 	label: 'Understanding the Structure',
                // 	items: [
                // 		{ label: 'Models', slug: 'structure/models' },
                //             { label: 'Assignable', slug: 'structure/assignable' }
                // 	]
                // },
              ],
            },
            {
              id: 'reference',
              label: 'Reference',
              link: '/reference/',
              icon: 'puzzle',
              items: [
                { label: 'About the Reference', link: 'reference/' },
                // {
                //   label: 'About the Reference', slug: 'reference/about-the-reference'
                // },
                {
                  label: 'API',
                  items: [
                    { label: 'Togglefy', slug: 'reference/api/togglefy' },
                    { label: 'Togglefy::FeatureQuery', slug: 'reference/api/togglefy-feature-query' },
                    { label: 'Togglefy::FeatureManager', slug: 'reference/api/togglefy-feature-manager' },
                    { label: 'Togglefy::FeatureAssignableManager', slug: 'reference/api/togglefy-feature-assignable-manager' },
                    { label: 'Togglefy::ScopedBulkWrapper', slug: 'reference/api/togglefy-scoped-bulk-wrapper' },
                  ]
                },
                {
                  label: 'Structure',
                  items: [
                    { label: 'Models', slug: 'reference/structure/models' },
                    {
                      label: 'Togglefy::Assignable',
                      slug: 'reference/structure/togglefy-assignable',
                      badge: { text: 'WIP', variant: 'caution' }
                    },
                    {
                      label: 'Togglefy::Feature',
                      slug: 'reference/structure/togglefy-feature',
                      badge: { text: 'WIP', variant: 'caution' }
                    },
                    {
                      label: 'Togglefy::FeatureAssignment',
                      slug: 'reference/structure/togglefy-feature-assignments',
                      badge: { text: 'WIP', variant: 'caution' }
                    },
                  ]
                },
                // { label: 'Structure', autogenerate: { directory: 'reference/structure' } },
                { label: 'Errors', autogenerate: { directory: 'reference/errors' }, collapsed: true },
              ],
              // badge: {
              //   text: 'Stub',
              //   variant: 'caution',
              // },
            },
            {
              label: 'Changelog',
              link: 'https://github.com/azeveco/Togglefy/releases',
              icon: 'add-document',
            },
          ]
        ),
      ]
    }),
  ],
  image: {
    service: sharpImageService(),
  },
  markdown: {
    remarkPlugins: [remarkHeadingId],
  },
});
