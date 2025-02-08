def trim_json_markers(input_str: str) -> str:
    start_marker = "json```"
    alt_start_marker = "```json"
    end_marker = "```"
    
    start_index = input_str.find(start_marker)
    if start_index == -1:
        start_index = input_str.find(alt_start_marker)
        if start_index != -1:
            start_index += len(alt_start_marker)
    else:
        start_index += len(start_marker)
    
    if start_index != -1:
        end_index = input_str.find(end_marker, start_index)
        if end_index != -1:
            return input_str[start_index:end_index].replace("\"\"\"", "\"")
    
    return input_str.replace("\"\"\"", "\"")