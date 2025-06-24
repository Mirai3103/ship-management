package com.ship.management.dto;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.Id;
import lombok.Data;

@Data
public class ChecklistItemDTO {
  
    private Long id;

    private String content;

    private String guide;

    private Integer orderNo = 0;

    private Long checklistTemplateId;

    private Long assignedToId;

    private String assignedToFullName;
    private String assignedToRoleName;
    private String assignedToRoleRootRole;
    private LocalDateTime comReviewAt;

    private LocalDateTime vesselReviewAt;

    private String vesselResult;

    private String vesselRemark;

    private Long comAssignedToId;
    private String comAssignedToFullName;
    private String comAssignedToRoleName;
    private String comAssignedToRoleRootRole;

    private String comResult;

    private String comRemark;

    private String note;

    private String status;

    private List<AttachmentDTO> attachments;
}
