# Runs a shell command and returns the stdout
module Shell
  extend Chef::Mixin::ShellOut

  def self.run(cmd)
    result = shell_out(cmd)
    unless result.status.success?
      fail "ShellOut error:\nSTDOUT\n#{result.stdout}\nSTDERR#{result.stderr}"
    end
    result.stdout
  end
end
