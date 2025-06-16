package com.ship.management.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.ship.management.dto.CopyCheckListDTO;
import com.ship.management.entity.ChecklistTemplate;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ship.management.dto.ChecklistItemDTO;
import com.ship.management.dto.ReviewDTO;
import com.ship.management.dto.UpdateItemDTO;
import com.ship.management.entity.ChecklistItem;
import com.ship.management.repository.ChecklistItemRepository;
import com.ship.management.repository.ChecklistTemplateRepository;
import com.ship.management.repository.ShipRepository;
import com.ship.management.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChecklistItemService {
    private final ChecklistItemRepository checklistItemRepository;
    private final ShipRepository shipRepository;

    private final ChecklistTemplateRepository checklistTemplateRepository;
    private final UserRepository userRepository;
    private final ModelMapper modelMapper;

    public ChecklistItemDTO createChecklistItem(ChecklistItemDTO checklistItemDTO) {
        var checklistItem = new ChecklistItem();
        checklistItem.setContent(checklistItemDTO.getContent());
        checklistItem.setGuide(checklistItemDTO.getGuide());
        checklistItem.setOrderNo(checklistItemDTO.getOrderNo());
        checklistItem.setChecklistTemplate(checklistTemplateRepository.findById(checklistItemDTO.getChecklistTemplateId()).orElseThrow(() -> new RuntimeException("Checklist template not found")));
        checklistItem.setAssignedTo(userRepository.findById(checklistItemDTO.getAssignedToId()).orElseThrow(() -> new RuntimeException("User not found")));
        checklistItem.setComAssignedTo(userRepository.findById(checklistItemDTO.getComAssignedToId()).orElseThrow(() -> new RuntimeException("User not found")));
        checklistItem = checklistItemRepository.save(checklistItem);
        return modelMapper.map(checklistItem, ChecklistItemDTO.class);
    }

    public void deleteChecklistItem(Long id) {
        checklistItemRepository.deleteById(id);
    }

    public ChecklistItemDTO updateChecklistItem(UpdateItemDTO updateItemDTO) {
        ChecklistItem checklistItem = checklistItemRepository.findById(updateItemDTO.getId()).orElseThrow(() -> new RuntimeException("Checklist item not found"));
        checklistItem.setContent(updateItemDTO.getContent());
        checklistItem.setGuide(updateItemDTO.getGuide());
        checklistItem.setOrderNo(updateItemDTO.getOrderNo());
        checklistItem.setAssignedTo(userRepository.findById(updateItemDTO.getAssignedToId()).orElseThrow(() -> new RuntimeException("User not found")));
        checklistItem.setComAssignedTo(userRepository.findById(updateItemDTO.getComAssignedToId()).orElseThrow(() -> new RuntimeException("User not found")));
        checklistItem = checklistItemRepository.save(checklistItem);
        return modelMapper.map(checklistItem, ChecklistItemDTO.class);
    }

    public ChecklistItemDTO reviewFromShip(ReviewDTO reviewDTO) {
        ChecklistItem checklistItem = checklistItemRepository.findById(reviewDTO.getChecklistItemId()).orElseThrow(() -> new RuntimeException("Checklist item not found"));
        checklistItem.setVesselResult(reviewDTO.getResult());
        checklistItem.setVesselRemark(reviewDTO.getRemark());
        checklistItem.setVesselReviewAt(LocalDateTime.now());
        checklistItemRepository.save(checklistItem);
        return new ChecklistItemDTO();
    }

    public ChecklistItemDTO reviewFromCompany(ReviewDTO reviewDTO) {
        ChecklistItem checklistItem = checklistItemRepository.findById(reviewDTO.getChecklistItemId()).orElseThrow(() -> new RuntimeException("Checklist item not found"));
        checklistItem.setComResult(reviewDTO.getResult());
        checklistItem.setComRemark(reviewDTO.getRemark());
        checklistItem.setComReviewAt(LocalDateTime.now());
        checklistItem.setNote(reviewDTO.getNote());
    checklistItemRepository.save(checklistItem);
        return new ChecklistItemDTO();
    }

    @Transactional
    public void  copyCheckListToShip(CopyCheckListDTO copyCheckListDTO) {
        var ship= shipRepository.findById(copyCheckListDTO.getShipId()).orElseThrow(() -> new RuntimeException("Ship not found"));
        var currentTemplates= checklistTemplateRepository.findByShipId(copyCheckListDTO.getShipId());
        var checklists = checklistItemRepository.findByIdIsIn((copyCheckListDTO.getItems().stream().map(CopyCheckListDTO.CopyCheckListItemDTO::getChecklistId).toList()));
        Map<ChecklistTemplate, List<ChecklistItem>> checklistMap = checklists.stream()
                .collect(Collectors.groupingBy(ChecklistItem::getChecklistTemplate));

//         đầu tiên kiếm mấy template trùng tên với cái có sẵn mà push vào
        currentTemplates.forEach(template -> {
            var incomingTemplate= checklistMap.get(template);
            if(incomingTemplate!=null){
               checklistItemRepository.saveAll(incomingTemplate.stream().map(item -> {
                var newItem = new ChecklistItem();
                newItem.setContent(item.getContent());
                newItem.setGuide(item.getGuide());
                newItem.setOrderNo(item.getOrderNo());
                newItem.setChecklistTemplate(template);
                return newItem;
               }).collect(Collectors.toList()));
               checklistMap.remove(template);
            }
        });


        // sau đó push vào checklist item mới
        checklistMap.keySet().forEach(template -> {
            var newTemplate = new ChecklistTemplate();
            newTemplate.setSection(template.getSection());
            newTemplate.setCompany(ship.getCompany());
            newTemplate.setShip(ship);
            final  ChecklistTemplate a = checklistTemplateRepository.save(newTemplate);
            checklistItemRepository.saveAll(checklistMap.get(template).stream().map(item -> {
                var newItem = new ChecklistItem();
                newItem.setContent(item.getContent());
                newItem.setGuide(item.getGuide());
                newItem.setOrderNo(item.getOrderNo());
                newItem.setChecklistTemplate(a);                                                    
                return newItem;
            }).collect(Collectors.toList()));                                                                           
        });
    }


    
}
