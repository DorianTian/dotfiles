--- Glow previewer for markdown files in Yazi
local M = {}

function M:peek(job)
  local child = Command("glow")
    :args({ "-s", "dark", "-w", tostring(job.area.w), tostring(job.file.url) })
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  local output = child:wait_with_output()
  if output and output.status and output.status.success then
    ya.preview_widgets(job, { ui.Text.parse(output.stdout):area(job.area) })
  else
    ya.preview_widgets(job, { ui.Text("Failed to preview"):area(job.area) })
  end
end

function M:seek(job)
  local h = cx.active.preview.skip + job.units
  ya.manager_emit("peek", { math.max(0, h), only_if = job.file.url, upper_bound = true })
end

return M
