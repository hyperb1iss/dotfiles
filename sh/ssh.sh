# ssh.sh
# Keep a forwarded ssh agent reachable from long-lived remote shells.
#
# A persistent server on a remote box (herdr server, tmux, an agent left
# running in a pane) inherits SSH_AUTH_SOCK from the connection that
# launched it. Tailscale SSH and OpenSSH both mint a fresh socket per
# connection and delete it on disconnect, so once that first connection
# ends every shell the server spawns holds a dead path: ssh-add -l says
# "Could not open a connection to your authentication agent" and git
# push over ssh prompts or fails, even though ForwardAgent is on.
#
# Every ssh shell therefore re-resolves the agent: keep SSH_AUTH_SOCK if
# it is still live, otherwise take the newest live socket any connection
# from this user has on the box. The result is published through
# ~/.ssh/agent.sock so a process that already started keeps working
# after the connection it came from is gone.

[ -n "${SSH_CONNECTION:-}" ] || return 0

__dotfiles_ssh_agent_link="${HOME}/.ssh/agent.sock"

# The newest live agent socket on this box, or nothing.
# Tailscale SSH: /tmp/auth-agent<id>/listener.sock. OpenSSH: /tmp/ssh-<id>/agent.<pid>.
__dotfiles_ssh_newest_agent() {
  local candidate newest=""
  if [ -n "${ZSH_VERSION:-}" ]; then
    setopt local_options null_glob
  fi
  for candidate in /tmp/auth-agent*/listener.sock /tmp/ssh-*/agent.*; do
    [ -S "${candidate}" ] || continue
    if [ -z "${newest}" ] || [ "${candidate}" -nt "${newest}" ]; then
      newest="${candidate}"
    fi
  done
  [ -n "${newest}" ] && printf '%s' "${newest}"
}

# Resolve the socket to point the link at, if anything changed.
__dotfiles_ssh_agent_target=""
case "${SSH_AUTH_SOCK:-}" in
  "${__dotfiles_ssh_agent_link}") ;;
  *)
    if [ -S "${SSH_AUTH_SOCK:-}" ]; then
      __dotfiles_ssh_agent_target="${SSH_AUTH_SOCK}"
    fi
    ;;
esac
if [ -z "${__dotfiles_ssh_agent_target}" ] && [ ! -S "${__dotfiles_ssh_agent_link}" ]; then
  __dotfiles_ssh_agent_target=$(__dotfiles_ssh_newest_agent)
fi

if [ -n "${__dotfiles_ssh_agent_target}" ]; then
  ln -sfn "${__dotfiles_ssh_agent_target}" "${__dotfiles_ssh_agent_link}" 2> /dev/null
fi

# Only redirect onto a link that resolves; a shell with no agent at all
# is better off with an unset variable than a dangling path.
if [ -S "${__dotfiles_ssh_agent_link}" ]; then
  export SSH_AUTH_SOCK="${__dotfiles_ssh_agent_link}"
fi

unset -f __dotfiles_ssh_newest_agent
unset __dotfiles_ssh_agent_link __dotfiles_ssh_agent_target
