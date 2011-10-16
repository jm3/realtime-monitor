worker_processes 4 # assuming four CPU cores

Rainbows! do
  use :FiberSpawn
  worker_connections 100
end

