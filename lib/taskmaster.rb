class Taskmaster

  VERSION = '1.0.0'
  TASKS   = {}

  def self.cookbook(&block)
    raise ArgumentError, "This requires a block" unless block
    return_block = instance_eval(&block)
    return_block unless missing_dependencies?
  end

  def self.task(t, *deps, &labor)
    TASKS[t] = { :deps  => deps, :labor => labor, :met => false }
  end

  def self.run(*jobs)
    jobs.each do |job|
      raise StandardError, recipeMissingMessage(job) unless TASKS[job]
      execute job
      puts "** done"
      TASKS.keys.each { |k| TASKS[k][:met] = false }
    end
  end

  def self.execute(job, nest=0)
    raise StandardError, recipeMissingMessage(job) unless TASKS[job]
    t = TASKS[job]
    i = "  " * nest
    if t[:met]
      puts "#{i}** Skipping completed dependency '#{job}'"
    else
      puts "#{i}** Executing#{" dependent" unless nest == 0} task '#{job}'"
      if t[:deps].any?
        t[:deps].each do |dep|
          self.execute dep, nest+1
        end
      end
      t[:labor].call
      t[:met] = true
    end
  end

  def self.recipeMissingMessage(job)
    "Task(s): #{job} not in Taskmaster cookbook"
  end
  
  def self.missing_dependencies?
    missing_deps = []
    TASKS.values.each do |v|
      v[:deps].each do |d|
        missing_deps << d unless TASKS[d]
      end
    end
    raise StandardError, recipeMissingMessage(missing_deps.join(", ")) unless missing_deps.empty?
  end
  
  def self.run_list_for job
    t = TASKS[job]
    deps = []
    t[:deps].each do |dep|
      deps << run_list_for(dep)
    end
    deps << job
    deps.flatten!
    deps.uniq!
    deps
  end
end

# New requirements:
# 
# * The server should keep the list of defined tasks for the life of the server that is, if you disconnect and reconnect the client, the tasks should stay defined
# * Add a method called "run_list_for" that takes a task name as an argument and returns the complete list of tasks, in order, to satisfy its dependencies and run the task
# 
# Notes:
# 
# * Running a single task multiple times should execute the dependencies each time that is, track the dependencies in the scope of a single Taskmaster.run call
