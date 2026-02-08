module Yabeda
  module FastRetro
    def self.install!
      Yabeda.configure do
        group :fast_retro

        gauge :active_retros_count, comment: "Number of retros currently in progress"
        gauge :retros_by_phase, tags: [ :phase ], comment: "Number of retros per phase"

        collect do
          active_phases = Retro.phases.keys - %w[waiting_room complete]

          fast_retro.active_retros_count.set({}, Retro.where(phase: active_phases).count)

          Retro.phases.each_key do |phase|
            fast_retro.retros_by_phase.set({ phase: phase }, Retro.where(phase: phase).count)
          end
        end
      end
    end
  end
end
