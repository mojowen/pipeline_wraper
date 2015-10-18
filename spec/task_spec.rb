require 'spec_helper'

RSpec.describe Task do
  it 'Retrieves information from remote' do
    task_id = task_factory
    task = Task.create task_id
    expect(task.id).to eq task_id
    assert_requested :get, "#{ENV['TASK_SERVER_URL']}/tasks/#{task_id}/"
  end
  it 'Recursively syncs sub tasks' do
    sub_tasks = 5.times.map { task_factory(sub_tasks_count: 3) }
    task_id = task_factory(sub_tasks: sub_tasks)

    task = Task.create task_id
    synced_sub_tasks = task.sub_tasks_synced.values

    # should retrieve sub_tasks correctly
    expect(synced_sub_tasks.map(&:id)).to eq(sub_tasks)

    # should retrieve sub_tasks' sub_tasks correctly
    synced_sub_tasks.each do |sb|
      assert_requested :get, "#{ENV['TASK_SERVER_URL']}/tasks/#{sb.id}/"
      next_sub_tasks = sb.sub_tasks.values
      next_synced_sub_tasks = sb.sub_tasks_synced.values

      next_sub_tasks.each do |nxt_sb|
        assert_requested :get, "#{ENV['TASK_SERVER_URL']}/tasks/#{nxt_sb}/"
      end

      next_synced_sub_tasks.each do |nxt_sb|
        expect(nxt_sb.class).to be Task
      end
    end

  end
  it 'Syncs task inputs to one layer' do
    inputs = 4.times.map { task_factory(sub_tasks_count: 3) }
    task_id = task_factory(inputs: inputs)

    task = Task.create task_id

    synced_inputs = task.inputs_synced.values

    synced_inputs.each do |sb|
      assert_requested :get, "#{ENV['TASK_SERVER_URL']}/tasks/#{sb.id}/"
      assert_not_requested :get,
        "#{ENV['TASK_SERVER_URL']}/tasks/#{sb.sub_tasks.first}/"
    end
  end
end
