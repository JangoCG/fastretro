class AlternativesController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access
  allow_search_engine_indexing
  layout "public"

  ALTERNATIVES = {
    easyretro: {
      name: "EasyRetro",
      slug: "easyretro",
      meta_title: "EasyRetro Alternative: Free Open Source Retro | Fast Retro",
      meta_description: "Switch from EasyRetro to a free, open-source retrospective tool. Self-host, flat per-account pricing, passwordless magic-link login. Start free.",
      meta_keywords: "easyretro alternative, free retrospective tool, open source retro tool, self-hosted retrospective",
      competitor_values: {
        pricing_model: "Tiered plans",
        paid_plan: "Board/team based tiers",
        open_source: "Not open source",
        self_hosting: "Not self-hosted",
        authentication: "Email/password",
        real_time: "Real-time collaboration",
        export: "Plan-dependent exports",
        free_tier: "Limited free usage"
      },
      reasons: [
        "Use one flat account price instead of scaling plan complexity as your retro usage grows.",
        "Run Fast Retro on your own infrastructure with full code visibility and no platform lock-in.",
        "Keep facilitation focused with an explicit phase flow from brainstorming to action items.",
        "Stay fast for teams with passwordless magic-link sign-in."
      ]
    },
    parabol: {
      name: "Parabol",
      slug: "parabol",
      meta_title: "Parabol Alternative: Free Open Source Retro | Fast Retro",
      meta_description: "Looking for a Parabol alternative? Fast Retro is a free, open-source retrospective tool. Flat account pricing, self-host, magic-link login. No seat fees.",
      meta_keywords: "parabol alternative, free retrospective tool, open source retro tool, self-hosted retrospective",
      competitor_values: {
        pricing_model: "Seat-based plans",
        paid_plan: "Per-active-user pricing",
        open_source: "Not open source",
        self_hosting: "Not self-hosted",
        authentication: "Account + workspace login",
        real_time: "Real-time collaboration",
        export: "Plan-dependent exports",
        free_tier: "Limited free usage"
      },
      reasons: [
        "Get a focused retro tool instead of a broader meeting stack when retros are your core workflow.",
        "Self-host when your organization requires infrastructure-level control.",
        "Keep costs predictable at the account level rather than user-based pricing growth.",
        "Adopt quickly with no-password login for every participant."
      ]
    },
    metroretro: {
      name: "Metro Retro",
      slug: "metroretro",
      meta_title: "Metro Retro Alternative: Free & Open Source | Fast Retro",
      meta_description: "Switch from Metro Retro to a free, open-source retrospective tool. Self-host for free, flat per-account pricing, magic-link login. Start your first retro free.",
      meta_keywords: "metro retro alternative, metroretro alternative, free retrospective tool, open source retro tool",
      competitor_values: {
        pricing_model: "Tiered plans",
        paid_plan: "Usage-based tiers",
        open_source: "Not open source",
        self_hosting: "Not self-hosted",
        authentication: "Account-based login",
        real_time: "Real-time collaboration",
        export: "Plan-dependent exports",
        free_tier: "Limited free usage"
      },
      reasons: [
        "Keep retros structured with explicit phases that reduce facilitation overhead.",
        "Own your deployment path with open source code and self-hosting support.",
        "Use straightforward account pricing as your team and session volume grows.",
        "Move faster in day-to-day usage with lightweight, passwordless sign-in."
      ]
    },
    teamretro: {
      name: "TeamRetro",
      slug: "teamretro",
      meta_title: "TeamRetro Alternative: Free Open Source Retro | Fast Retro",
      meta_description: "TeamRetro feels heavy? Fast Retro is a free, open-source retrospective tool. Self-host, flat account pricing, magic-link login. No per-seat fees.",
      meta_keywords: "teamretro alternative, free retrospective tool, open source retro tool, scrum retrospective software",
      competitor_values: {
        pricing_model: "Tiered plans",
        paid_plan: "Seat and plan based pricing",
        open_source: "Not open source",
        self_hosting: "Not self-hosted",
        authentication: "Account + workspace login",
        real_time: "Real-time collaboration",
        export: "Plan-dependent exports",
        free_tier: "Limited free usage"
      },
      reasons: [
        "Avoid user-count pricing complexity with one account-level paid plan.",
        "Self-host for free when procurement or compliance requires it.",
        "Run a consistent facilitation pattern every sprint with a fixed phase sequence.",
        "Keep onboarding friction low for teams using magic-link authentication."
      ]
    },
    quickretro: {
      name: "QuickRetro",
      slug: "quickretro",
      meta_title: "QuickRetro Alternative: Free Open Source Retro | Fast Retro",
      meta_description: "Looking for a QuickRetro alternative? Fast Retro is a free, open-source sprint retrospective tool. Self-host, flat account pricing, magic-link login.",
      meta_keywords: "quickretro alternative, quick retro alternative, free retrospective tool, open source retro tool",
      competitor_values: {
        pricing_model: "Freemium with paid tiers",
        paid_plan: "Team-size based pricing",
        open_source: "Not open source",
        self_hosting: "Not self-hosted",
        authentication: "Account-based login",
        real_time: "Real-time collaboration",
        export: "Plan-dependent exports",
        free_tier: "Limited free boards"
      },
      reasons: [
        "Keep retros structured with explicit phases instead of a freeform board.",
        "Own your data and deployment with open source code and self-hosting support.",
        "Use predictable flat account pricing as your team grows.",
        "Onboard teammates fast with passwordless magic-link sign-in."
      ]
    },
    reetro: {
      name: "Reetro",
      slug: "reetro",
      meta_title: "Reetro Alternative: Free Open Source Retro | Fast Retro",
      meta_description: "Looking for a Reetro alternative? Fast Retro is a free, open-source retrospective tool. Self-host, flat per-account pricing, magic-link login. Start free.",
      meta_keywords: "reetro alternative, reetro app alternative, free retrospective tool, open source retro tool",
      competitor_values: {
        pricing_model: "Freemium with paid tiers",
        paid_plan: "Per-team paid plans",
        open_source: "Not open source",
        self_hosting: "Not self-hosted",
        authentication: "Account-based login",
        real_time: "Real-time collaboration",
        export: "Plan-dependent exports",
        free_tier: "Limited free usage"
      },
      reasons: [
        "Run structured retros with a fixed phase flow instead of a single-board layout.",
        "Self-host the whole stack when compliance or procurement requires it.",
        "Keep billing predictable with a flat per-account paid plan.",
        "Reduce friction for participants using passwordless magic-link login."
      ]
    },
    funretro: {
      name: "FunRetro",
      slug: "funretro",
      meta_title: "FunRetro Alternative: Free Open Source Retro | Fast Retro",
      meta_description: "Looking for a FunRetro alternative? Fast Retro is a free, open-source sprint retrospective tool. Self-host, flat per-account pricing, magic-link login.",
      meta_keywords: "funretro alternative, funretro retrospective tool alternative, free retrospective tool, open source retro tool",
      competitor_values: {
        pricing_model: "Tiered plans",
        paid_plan: "Board/team based tiers",
        open_source: "Not open source",
        self_hosting: "Not self-hosted",
        authentication: "Email/password",
        real_time: "Real-time collaboration",
        export: "Plan-dependent exports",
        free_tier: "Limited free usage"
      },
      reasons: [
        "Move from FunRetro's board model to an explicit phase-based facilitation flow.",
        "Self-host with full code visibility instead of depending on a hosted-only SaaS.",
        "Use one flat account price instead of scaling plan tiers as retros grow.",
        "Keep participant onboarding fast with magic-link sign-in."
      ]
    }
  }.freeze

  FAST_RETRO_FEATURES = [
    "Optional action-item review before starting a new retro",
    "Anonymous brainstorming across \"went well\" and \"could be better\"",
    "Drag-and-drop grouping of related feedback",
    "Dot voting with per-participant vote limits",
    "Discussion phase with action-item creation",
    "Real-time updates via Turbo Streams",
    "Export retro results (CSV/XLSX)",
    "Passwordless magic-link authentication"
  ].freeze

  before_action :redirect_authenticated_user

  def easyretro
    render_alternative(:easyretro)
  end

  def parabol
    render_alternative(:parabol)
  end

  def metroretro
    render_alternative(:metroretro)
  end

  def teamretro
    render_alternative(:teamretro)
  end

  def quickretro
    render_alternative(:quickretro)
  end

  def reetro
    render_alternative(:reetro)
  end

  def funretro
    render_alternative(:funretro)
  end

  private
    def render_alternative(key)
      @free_limit = Plan.free.retro_limit
      @paid_price = Plan.paid.price_for_display
      @alternative = ALTERNATIVES.fetch(key)
      @comparison_rows = comparison_rows(@alternative.fetch(:competitor_values))
      @fast_retro_features = FAST_RETRO_FEATURES
      @other_alternatives = ALTERNATIVES.values.reject { |alternative| alternative[:slug] == @alternative[:slug] }

      render :show
    rescue Plan::StripePriceUnavailableError => error
      @paid_price = nil
      @alternative = ALTERNATIVES.fetch(key)
      @comparison_rows = comparison_rows(@alternative.fetch(:competitor_values))
      @fast_retro_features = FAST_RETRO_FEATURES
      @other_alternatives = ALTERNATIVES.values.reject { |alternative| alternative[:slug] == @alternative[:slug] }
      flash.now[:alert] = error.message
      render :show
    end

    def comparison_rows(competitor_values)
      [
        { feature: "Pricing model", fast_retro: "Flat per-account pricing", competitor: competitor_values.fetch(:pricing_model) },
        { feature: "Paid plan", fast_retro: "Single paid plan", competitor: competitor_values.fetch(:paid_plan) },
        { feature: "Open source", fast_retro: "100% open source", competitor: competitor_values.fetch(:open_source) },
        { feature: "Self-hosting", fast_retro: "Yes, self-host for free", competitor: competitor_values.fetch(:self_hosting) },
        { feature: "Authentication", fast_retro: "Passwordless magic link", competitor: competitor_values.fetch(:authentication) },
        { feature: "Real-time collaboration", fast_retro: "Turbo Stream updates", competitor: competitor_values.fetch(:real_time) },
        { feature: "Export support", fast_retro: "CSV and XLSX export", competitor: competitor_values.fetch(:export) },
        { feature: "Free tier", fast_retro: "#{Plan.free.retro_limit} retros", competitor: competitor_values.fetch(:free_tier) }
      ]
    end

    def redirect_authenticated_user
      if authenticated? && Current.account.blank?
        redirect_to session_menu_url(script_name: nil)
      end
    end
end
