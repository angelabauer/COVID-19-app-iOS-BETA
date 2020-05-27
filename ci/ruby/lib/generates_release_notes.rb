require 'git'
require 'tracker'

module GeneratesReleaseNotes
  include Git

  def generate_release_notes(
    io:,
    tracker_token:,
    commits: 'HEAD..HEAD',
    git_dir: Dir.pwd
  )
    tracker = Tracker.new(tracker_token)
    status, = tracker.me
    raise 'unable to authenticate with pivotal tracker' if status != :success

    story_ids = git_logs(git_dir, commits)
      .scan(/\[Finishes #(\d+)\]/i)
      .map {|m| m[0] }
      .uniq

    if story_ids.empty?
      io.puts('No changes')
      return
    end

    io.puts("Changes (#{commits})")
    io.puts

    story_ids.each do |story_id|
      _, story = tracker.story(story_id)
      story_url = story.fetch('url')
      story_name = story.fetch('name')
      io.puts("  * [##{story_id}](#{story_url}) - #{story_name}")
    end
  end
end