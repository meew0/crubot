require "json"

module Crubot
  struct User
    JSON.mapping(
      login: String,
      id: UInt64
    )
  end

  struct Repository
    JSON.mapping(
      name: String,
      full_name: String
    )
  end

  struct Label
    JSON.mapping(
      name: String
    )
  end

  struct Issue
    JSON.mapping(
      number: Int32,
      title: String,
      html_url: String,
      labels: {type: Array(Label), nilable: true},
      merged: {type: Bool, nilable: true}
    )

    def tiny_issue
      "**##{@number}** (" + %(**#{@title}**) + (@labels.try &.map { |e| " `[#{e.name}]`"}.join || "") + ")"
    end

    def format_issue
      %(**##{@number}**
   **#{@title}** #{@labels.try &.map { |e| " `[#{e.name}]`"}.join(" ")}
  <#{@html_url}>)
    end
  end

  struct IssueComment
    JSON.mapping(
      html_url: String
    )
  end

  struct CommitAuthor
    JSON.mapping(
      username: String
    )
  end

  struct Commit
    JSON.mapping(
      id: String,
      message: String,
      author: CommitAuthor,
      committer: CommitAuthor
    )

    def format_commit
      sha = "`#{@id[0..6]}` "
      message = @message.lines[0].strip
      author = " [#{@author.username}]"
      sha + message + author
    end
  end

  struct IssuesEvent
    JSON.mapping(
      action: String,
      issue: Issue,
      repository: Repository,
      assignee: {type: User, nilable: true},
      label: {type: Label, nilable: true},
      sender: User
    )

    def to_s
      case @action
      when "opened"
        %(opened issue #{@issue.format_issue})
      when "reopened"
        %(re-opened issue #{@issue.format_issue})
      when "closed"
        %(closed issue #{@issue.format_issue})
      when "edited"
        %(edited issue #{@issue.format_issue})
      when "assigned"
        %(assigned issue #{@issue.tiny_issue} to **#{@assignee.try &.login}**
<#{@issue.html_url}>)
      when "unassigned"
        %(unassigned issue #{@issue.tiny_issue} from **#{@assignee.try &.login}**
<#{@issue.html_url}>)
      when "labeled"
        %(added label `[#{@label.try &.name}]` to issue #{@issue.tiny_issue}
<#{@issue.html_url}>)
      when "unlabeled"
        %(removed label `[#{@label.try &.name}]` from issue #{@issue.tiny_issue}
<#{@issue.html_url}>)
      else
        ""
      end
    end
  end

  struct PullRequestEvent
    JSON.mapping(
      action: String,
      pull_request: Issue, # identical in format
      repository: Repository,
      assignee: {type: User, nilable: true},
      label: {type: Label, nilable: true},
      sender: User
    )

    def to_s
      case @action
      when "opened"
        %(opened pull request #{@pull_request.format_issue})
      when "reopened"
        %(re-opened pull request #{@pull_request.format_issue})
      when "closed"
        %(#{@pull_request.merged ? "merged" : "closed"} pull request #{@pull_request.format_issue})
      when "edited"
        %(edited pull request #{@pull_request.format_issue})
      when "assigned"
        %(assigned pull request #{@pull_request.tiny_issue} to **#{@assignee.try &.login}**
<#{@pull_request.html_url}>)
      when "unassigned"
        %(unassigned pull request #{@pull_request.tiny_issue} from **#{@assignee.try &.login}**
<#{@pull_request.html_url}>)
      when "labeled"
        %(added label `[#{@label.try &.name}]` to pull request #{@pull_request.tiny_issue}
<#{@pull_request.html_url}>)
      when "unlabeled"
        %(removed label `[#{@label.try &.name}]` from pull request #{@pull_request.tiny_issue}
<#{@pull_request.html_url}>)
    when "synchronize"
        %(updated pull request #{@pull_request.tiny_issue} with new commits
<#{@pull_request.html_url}>)
      else
        ""
      end
    end
  end

  struct CreateEvent
    JSON.mapping(
      repository: Repository,
      sender: User,
      ref_type: String,
      ref: String
    )

    def to_s
      "created #{@ref_type} **#{@ref}**"
    end
  end

  struct DeleteEvent
    JSON.mapping(
      repository: Repository,
      sender: User,
      ref_type: String,
      ref: String
    )

    def to_s
      "deleted #{@ref_type} **#{@ref}**"
    end
  end

  struct IssueCommentEvent
    JSON.mapping(
      repository: Repository,
      sender: User,
      issue: Issue,
      comment: IssueComment,
      action: String
    )

    def to_s
      if @action == "created"
        participle = "commented"
      else
        participle = @action + " a comment"
      end

      %(#{participle} on issue #{@issue.tiny_issue}
<#{@comment.html_url}>)
    end
  end

  struct PushEvent
    JSON.mapping(
      repository: Repository,
      sender: User,
      commits: Array(Commit),
      ref: String
    )

    def to_s
      split_ref = @ref.split("/")
      ctype = split_ref[1]
      name = split_ref[2..-1].join("/")
      case ctype
      when "heads" # branch
        str = "pushed **#{@commits.size}** commit#{@commits.size == 1 ? "" : "s"} to branch **#{name}**\n"
        str += @commits.map { |e| e.format_commit }.join("\n")
        str
      else
        ""
      end
    end
  end

  struct ForkEvent
    JSON.mapping(
      repository: Repository,
      sender: User,
      forkee: Repository
    )

    def to_s
      "forked this repo to **#{@forkee.full_name}**."
    end
  end

  struct WatchEvent
    JSON.mapping(
      repository: Repository,
      sender: User
    )

    def to_s
      "starred this repo!"
    end
  end

  struct BasicEvent
    JSON.mapping(
      repository: Repository,
      sender: User
    )

    def to_s
      ""
    end
  end
end
