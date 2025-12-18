class PhaseTagComponent < ApplicationComponent
  PHASE_CONFIG = {
    action_review: {
      title: "ACTION\nREVIEW",
      instruction: "Review action items from your previous retro.",
      footer: "CHECK PROGRESS.",
      bg_color: "bg-violet-50",
      border_color: "border-violet-300",
      stripe_hex: "#7c3aed",
      accent_color: "text-violet-700"
    },
    brainstorming: {
      title: "BRAIN\nSTORMING",
      instruction: "Write down your ideas. No one can see them yet",
      footer: "WAIT FOR SIGNAL.",
      bg_color: "bg-amber-50",
      border_color: "border-amber-300",
      stripe_hex: "#d97706",
      accent_color: "text-amber-700"
    },
    grouping: {
      title: "GROUPING",
      instruction: "Organize similar ideas into clusters.",
      footer: "COLLABORATE.",
      bg_color: "bg-sky-50",
      border_color: "border-sky-300",
      stripe_hex: "#0284c7",
      accent_color: "text-sky-700"
    },
    voting: {
      title: "VOTING",
      instruction: "Vote on the most important topics.",
      footer: "CHOOSE WISELY.",
      bg_color: "bg-violet-50",
      border_color: "border-violet-300",
      stripe_hex: "#7c3aed",
      accent_color: "text-violet-700"
    },
    discussion: {
      title: "DISCUSSION",
      instruction: "Discuss top-voted items and create actions.",
      footer: "TAKE ACTION.",
      bg_color: "bg-emerald-50",
      border_color: "border-emerald-300",
      stripe_hex: "#059669",
      accent_color: "text-emerald-700"
    },
    complete: {
      title: "COMPLETE",
      instruction: "Review your action items and outcomes.",
      footer: "WELL DONE!",
      bg_color: "bg-zinc-50",
      border_color: "border-zinc-400",
      stripe_hex: "#18181b",
      accent_color: "text-zinc-700"
    }
  }.freeze

  def initialize(phase: nil, phase_title: nil, phase_instruction: nil, phase_footer: nil, rotation: -6)
    @phase = phase&.to_sym
    @phase_title = phase_title
    @phase_instruction = phase_instruction
    @phase_footer = phase_footer
    @rotation = rotation
  end

  def rotation_style
    "transform: rotate(#{@rotation}deg);"
  end

  def phase_title
    @phase_title || config[:title] || @phase.to_s.humanize.upcase
  end

  def phase_instruction
    @phase_instruction || config[:instruction] || ""
  end

  def phase_footer
    @phase_footer || config[:footer] || ""
  end

  def bg_color
    config[:bg_color] || "bg-[#F8F5EC]"
  end

  def border_color
    config[:border_color] || "border-stone-300"
  end

  def stripe_style
    hex = config[:stripe_hex] || "#000"
    "background: repeating-linear-gradient(-45deg, #{hex}, #{hex} 10px, transparent 10px, transparent 20px);"
  end

  def accent_color
    config[:accent_color] || "text-stone-700"
  end

  private

  def config
    return {} unless @phase
    PHASE_CONFIG[@phase] || {}
  end
end
