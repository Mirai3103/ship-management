package com.ship.management.api;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ship.management.dto.ChecklistItemDTO;
import com.ship.management.service.ChecklistItemService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/checklist-items")
@RequiredArgsConstructor
public class ChecklistItemController {
    private final ChecklistItemService checklistItemService;

    @PostMapping
    public ChecklistItemDTO createChecklistItem(@RequestBody ChecklistItemDTO checklistItemDTO) {
        return checklistItemService.createChecklistItem(checklistItemDTO);
    }
}
