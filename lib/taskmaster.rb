require 'drb'

module Taskmaster

  include DRbUndumped

  VERSION = '1.0.0'
  TASKS   = {}

  def self.cookbook(&block)
    raise ArgumentError, "This requires a block" unless block
    return_block = module_eval(&block)
    return_block unless missing_dependencies?
  end
  
  def self.returnTasks
    TASKS
  end

  def self.task(t, *deps, &labor)
    TASKS[t] = { :deps  => deps, :labor => labor }
  end

  def self.run(*jobs)
    jobs.each { |job| execute job }
  end


  def self.execute(job_list)
    [job_list].flatten.each do |job|
      raise StandardError, recipeMissingMessage(job) unless TASKS[job]
      puts "** Executing task '#{job}'"
      TASKS[job][:labor].call
    end
    puts "** done"
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
    false if missing_deps.empty?
  end
  
  def self.run_list_for(job)
    raise StandardError, recipeMissingMessage(job) unless TASKS[job]
    t    = TASKS[job]
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