<template>
  <header class="navbar">
    
    <div class="navbar-inner">

      <SidebarButton
        @toggle-sidebar="$emit('toggle-sidebar')"
      />

      <div class="logo-wrap">
        <router-link
          :to="$localePath"
          class="home-link"
        >
          <img
            class="logo"
            v-if="$site.themeConfig.logo"
            :src="$withBase($site.themeConfig.logo)"
            :alt="$siteTitle"
          >
          <span
            ref="siteName"
            class="site-name"
            v-if="$siteTitle"
            :class="{ 'can-hide': $site.themeConfig.logo }"
          >{{ $siteTitle }}</span>
        </router-link>

        <GithubButton
          v-if="getSiteData.themeConfig.repo"
          :href="getSiteData.themeConfig.repo"
          class="repo-button"
          data-icon="octicon-star"
          data-size="small"
          data-show-count="false"
          aria-label="Star Kuma on GitHub"
        >
          {{
            getSiteData.themeConfig.repoButtonLabel 
              ? getSiteData.themeConfig.repoButtonLabel 
              : 'Star'
          }}
        </GithubButton>
      </div>
      <!-- .logo-wrap -->

      <div
        class="links"
        :style="linksWrapMaxWidth ? {
          'max-width': linksWrapMaxWidth + 'px'
        } : {}"
      >
        <NavLinks class="can-hide"/>
      </div>

    </div>

  </header>
</template>

<script>
import SidebarButton from '@theme/components/SidebarButton.vue'
import NavLinks from '@theme/components/NavLinks.vue'
import GithubButton from 'vue-github-button'

export default {
  components: { SidebarButton, NavLinks, GithubButton },

  data () {
    return {
      linksWrapMaxWidth: null
    }
  },

  mounted () {
    const MOBILE_DESKTOP_BREAKPOINT = 719 // refer to config.styl
    const NAVBAR_VERTICAL_PADDING = parseInt(css(this.$el, 'paddingLeft')) + parseInt(css(this.$el, 'paddingRight'))
    const handleLinksWrapWidth = () => {
      if (document.documentElement.clientWidth < MOBILE_DESKTOP_BREAKPOINT) {
        this.linksWrapMaxWidth = null
      } else {
        this.linksWrapMaxWidth = this.$el.offsetWidth - NAVBAR_VERTICAL_PADDING
          - (this.$refs.siteName && this.$refs.siteName.offsetWidth || 0)
      }
    }
    handleLinksWrapWidth()
    window.addEventListener('resize', handleLinksWrapWidth, false)
  },
  computed: {}
}

function css (el, property) {
  // NOTE: Known bug, will return 'auto' if style value is 'auto'
  const win = el.ownerDocument.defaultView
  // null means not to return pseudo styles
  return win.getComputedStyle(el, null)[property]
}
</script>
