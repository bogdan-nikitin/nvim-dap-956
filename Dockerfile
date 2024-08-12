FROM ubuntu
COPY <<-EOT /main.cpp
int main() {}
EOT
RUN <<EOT
    apt update  
    # DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y git lldb=1:18.0-59~exp2 clang wget
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y git clang wget unzip neovim
    git clone https://github.com/mfussenegger/nvim-dap.git ~/.config/nvim/pack/plugins/start/nvim-dap
    wget https://github.com/vadimcn/codelldb/releases/download/v1.10.0/codelldb-`arch`-linux.vsix
    unzip codelldb-`arch`-linux.vsix
EOT
RUN clang++ --debug /main.cpp
COPY <<-"EOT" /root/.config/nvim/init.lua
local dap = require('dap')

dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        command = 'extension/adapter/codelldb',
        args = {"--port", "${port}"},
    }
}

dap.adapters.cpp = dap.adapters.codelldb

dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
            return '/a.out'
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
    },
}
EOT
CMD ["nvim", "main.cpp", "+1", "-c", "DapToggleBreakpoint"]
