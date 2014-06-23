module Shell
  extend Chef::Mixin::ShellOut

  def self.run(cmd)
    result = shell_out(cmd)
    raise "ShellOut error:\nSTDOUT\n#{result.stdout}\nSTDERR#{result.stderr}" unless result.status.success?
    result.stdout
  end
end
