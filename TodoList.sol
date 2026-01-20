// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {
    struct Task {
        uint256 id;
        string description;
        bool completed;
        Priority priority;
        string category;
        uint256 dueDate;
    }
    
    enum Priority {
        None,
        Low,
        Medium,
        High
    }
    
    mapping(address => Task[]) private userTasks;
    mapping(address => uint256) private taskCount;
    
    event TaskAdded(address indexed user, uint256 taskId, string description, Priority priority);
    event TaskCompleted(address indexed user, uint256 taskId);
    event TaskRemoved(address indexed user, uint256 taskId);
    event TaskEdited(address indexed user, uint256 taskId, string newDescription);
        
    function addTask(
        string memory _description,
        Priority _priority,
        string memory _category,
        uint256 _dueDate
    ) public {
        uint256 newTaskId = taskCount[msg.sender];
        
        Task memory newTask = Task({
            id: newTaskId,
            description: _description,
            completed: false,
            priority: _priority,
            category: _category,
            dueDate: _dueDate
        });
        
        userTasks[msg.sender].push(newTask);
        taskCount[msg.sender]++;
        
        emit TaskAdded(msg.sender, newTaskId, _description, _priority);
    }
    
    function markTaskCompleted(uint256 _taskId) public {
        require(_taskId < taskCount[msg.sender], "Task does not exist");
        require(!userTasks[msg.sender][_taskId].completed, "Task already completed");
        
        userTasks[msg.sender][_taskId].completed = true;
        emit TaskCompleted(msg.sender, _taskId);
    }
    
    function removeTask(uint256 _taskId) public {
        require(_taskId < taskCount[msg.sender], "Task does not exist");
        
        uint256 lastIndex = userTasks[msg.sender].length - 1;
        
        if (_taskId != lastIndex) {
            userTasks[msg.sender][_taskId] = userTasks[msg.sender][lastIndex];
            userTasks[msg.sender][_taskId].id = _taskId;
        }
        
        userTasks[msg.sender].pop();
        taskCount[msg.sender]--;
        
        emit TaskRemoved(msg.sender, _taskId);
    }
    
    function editTask(uint256 _taskId, string memory _newDescription) public {
        require(_taskId < taskCount[msg.sender], "Task does not exist");
        
        userTasks[msg.sender][_taskId].description = _newDescription;
        emit TaskEdited(msg.sender, _taskId, _newDescription);
    }
    
    function updateTaskPriority(uint256 _taskId, Priority _newPriority) public {
        require(_taskId < taskCount[msg.sender], "Task does not exist");
        userTasks[msg.sender][_taskId].priority = _newPriority;
    }
        
    function getAllTasks() public view returns (Task[] memory) {
        return userTasks[msg.sender];
    }
    
    function getTask(uint256 _taskId) public view returns (Task memory) {
        require(_taskId < taskCount[msg.sender], "Task does not exist");
        return userTasks[msg.sender][_taskId];
    }
    
    function getTasksByStatus(bool _completed) public view returns (Task[] memory) {
        Task[] memory allTasks = userTasks[msg.sender];
        uint256 count = 0;
        
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (allTasks[i].completed == _completed) {
                count++;
            }
        }
        
        Task[] memory filtered = new Task[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (allTasks[i].completed == _completed) {
                filtered[index] = allTasks[i];
                index++;
            }
        }
        
        return filtered;
    }
    
    function getTasksByCategory(string memory _category) public view returns (Task[] memory) {
        Task[] memory allTasks = userTasks[msg.sender];
        uint256 count = 0;
        
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (keccak256(bytes(allTasks[i].category)) == keccak256(bytes(_category))) {
                count++;
            }
        }
        
        Task[] memory filtered = new Task[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (keccak256(bytes(allTasks[i].category)) == keccak256(bytes(_category))) {
                filtered[index] = allTasks[i];
                index++;
            }
        }
        
        return filtered;
    }
    
    function getTasksSortedByPriority() public view returns (Task[] memory) {
        Task[] memory tasks = userTasks[msg.sender];
        
        // Make a copy to sort
        Task[] memory sorted = new Task[](tasks.length);
        for (uint256 i = 0; i < tasks.length; i++) {
            sorted[i] = tasks[i];
        }
        
        for (uint256 i = 0; i < sorted.length; i++) {
            for (uint256 j = 0; j < sorted.length - i - 1; j++) {
                if (uint(sorted[j].priority) < uint(sorted[j + 1].priority)) {
                    Task memory temp = sorted[j];
                    sorted[j] = sorted[j + 1];
                    sorted[j + 1] = temp;
                }
            }
        }
        
        return sorted;
    }
    
    function getPendingTasksWithDueDates() public view returns (Task[] memory) {
        Task[] memory allTasks = userTasks[msg.sender];
        uint256 count = 0;
        
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (!allTasks[i].completed && allTasks[i].dueDate > 0) {
                count++;
            }
        }
        
        Task[] memory filtered = new Task[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (!allTasks[i].completed && allTasks[i].dueDate > 0) {
                filtered[index] = allTasks[i];
                index++;
            }
        }
        
        return filtered;
    }
    
    function getTaskCount() public view returns (uint256) {
        return taskCount[msg.sender];
    }
    
    function getCompletedCount() public view returns (uint256) {
        uint256 count = 0;
        Task[] memory tasks = userTasks[msg.sender];
        
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].completed) {
                count++;
            }
        }
        
        return count;
    }
}