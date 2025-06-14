package com.ship.management.api;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ship.management.dto.ChecklistItemDTO;
import com.ship.management.dto.UpdateItemDTO;
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

    @DeleteMapping("/{id}")
    public void deleteChecklistItem(@PathVariable Long id) {
        checklistItemService.deleteChecklistItem(id);
    }

    @PatchMapping("/{id}")
    public ChecklistItemDTO updateChecklistItem(@PathVariable Long id, @RequestBody UpdateItemDTO updateItemDTO) {
        updateItemDTO.setId(id);
        return checklistItemService.updateChecklistItem(updateItemDTO);
    }
}
