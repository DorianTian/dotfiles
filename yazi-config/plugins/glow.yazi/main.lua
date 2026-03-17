local M = {}

function M:peek(job)
  local output = Command("/opt/homebrew/bin/glow")
    :arg("-s"):arg("dark")
    :arg("-w"):arg(tostring(job.area.w))
    :arg(tostring(job.file.url))
    :stdout(Command.PIPED)
    :stderr(Command.NULL)
    :output()

  if output and output.status and output.status.success then
    local lines = {}
    for line in output.stdout:gmatch("([^\n]*)\n?") do
      lines[#lines + 1] = line
    end

    local skip = math.max(0, math.min(job.skip or 0, #lines - 1))
    local visible = {}
    for i = skip + 1, #lines do
      visible[#visible + 1] = lines[i]
    end

    ya.preview_widget(job, { ui.Text.parse(table.concat(visible, "\n")):area(job.area) })
  else
    ya.preview_widget(job, { ui.Text("glow failed"):area(job.area) })
  end
end

function M:seek(job)
  local new_skip = math.max(0, job.skip + job.units)
  ya.emit("peek", { new_skip, only_if = job.file.url, upper_bound = true })
end

return M
