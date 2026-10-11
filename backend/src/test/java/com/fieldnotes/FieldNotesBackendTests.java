package com.fieldnotes;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fieldnotes.dto.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class FieldNotesBackendTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String user1Token;
    private String user2Token;

    @BeforeEach
    public void setUp() throws Exception {
        // Register and login User 1
        String u1 = "user1_" + UUID.randomUUID().toString().substring(0, 8);
        RegisterRequest reg1 = new RegisterRequest();
        reg1.setUsername(u1);
        reg1.setEmail(u1 + "@example.com");
        reg1.setPassword("password123");
        reg1.setFullName("Field Worker One");

        MvcResult res1 = mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(reg1)))
                .andExpect(status().isOk())
                .andReturn();
        AuthResponse auth1 = objectMapper.readValue(res1.getResponse().getContentAsString(), AuthResponse.class);
        user1Token = "Bearer " + auth1.getToken();

        // Register and login User 2 (for testing data isolation)
        String u2 = "user2_" + UUID.randomUUID().toString().substring(0, 8);
        RegisterRequest reg2 = new RegisterRequest();
        reg2.setUsername(u2);
        reg2.setEmail(u2 + "@example.com");
        reg2.setPassword("password123");
        reg2.setFullName("Field Worker Two");

        MvcResult res2 = mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(reg2)))
                .andExpect(status().isOk())
                .andReturn();
        AuthResponse auth2 = objectMapper.readValue(res2.getResponse().getContentAsString(), AuthResponse.class);
        user2Token = "Bearer " + auth2.getToken();
    }

    @Test
    public void testCustomerSiteNoteLifecycleAndRelationalSearch() throws Exception {
        // 1. Create Customer for User 1
        CustomerDto custReq = new CustomerDto();
        custReq.setName("Acme Solar Corp");
        custReq.setContactInformation("contact@acmesolar.com | +1 555 1234");

        MvcResult custResult = mockMvc.perform(post("/api/customers")
                        .header("Authorization", user1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(custReq)))
                .andExpect(status().isOk())
                .andReturn();
        CustomerDto custRes = objectMapper.readValue(custResult.getResponse().getContentAsString(), CustomerDto.class);
        assertThat(custRes.getId()).isNotNull();
        assertThat(custRes.getName()).isEqualTo("Acme Solar Corp");

        // 2. Create Site under Customer
        SiteDto siteReq = new SiteDto();
        siteReq.setCustomerId(custRes.getId());
        siteReq.setName("North Valley Array 4");
        siteReq.setAddress("456 Solar Way, Sector 9");

        MvcResult siteResult = mockMvc.perform(post("/api/sites")
                        .header("Authorization", user1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(siteReq)))
                .andExpect(status().isOk())
                .andReturn();
        SiteDto siteRes = objectMapper.readValue(siteResult.getResponse().getContentAsString(), SiteDto.class);
        assertThat(siteRes.getId()).isNotNull();
        assertThat(siteRes.getCustomerName()).isEqualTo("Acme Solar Corp");

        // 3. Create Field Note under Site
        FieldNoteDto noteReq = new FieldNoteDto();
        noteReq.setSiteId(siteRes.getId());
        noteReq.setTitle("Inverter Inspection Q4");
        noteReq.setDescription("Found loose cabling on panel bank B. Repaired wiring connector.");
        noteReq.setLatitude(37.7749);
        noteReq.setLongitude(-122.4194);
        noteReq.setLocationName("Building B Rooftop");
        noteReq.setStatus("In Progress");
        noteReq.setDateTime(Instant.now());

        MvcResult noteResult = mockMvc.perform(post("/api/notes")
                        .header("Authorization", user1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(noteReq)))
                .andExpect(status().isOk())
                .andReturn();
        FieldNoteDto noteRes = objectMapper.readValue(noteResult.getResponse().getContentAsString(), FieldNoteDto.class);
        assertThat(noteRes.getId()).isNotNull();
        assertThat(noteRes.getSiteName()).isEqualTo("North Valley Array 4");
        assertThat(noteRes.getCustomerName()).isEqualTo("Acme Solar Corp");

        // 4. Test Relational Search by Title
        mockMvc.perform(get("/api/notes?query=Inverter")
                        .header("Authorization", user1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("Inverter Inspection Q4"));

        // 5. Test Relational Search by Customer Name
        mockMvc.perform(get("/api/notes?query=Acme")
                        .header("Authorization", user1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].customerName").value("Acme Solar Corp"));

        // 6. Test Relational Search by Site Name
        mockMvc.perform(get("/api/notes?query=North Valley")
                        .header("Authorization", user1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].siteName").value("North Valley Array 4"));

        // 7. Test Filter by Status
        mockMvc.perform(get("/api/notes?status=In Progress")
                        .header("Authorization", user1Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].status").value("In Progress"));

        // 8. Test Data Isolation (User 2 should see 0 customers, 0 sites, 0 notes)
        mockMvc.perform(get("/api/customers")
                        .header("Authorization", user2Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));

        mockMvc.perform(get("/api/notes")
                        .header("Authorization", user2Token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    public void testOfflinePushAndPullSync() throws Exception {
        String custId = UUID.randomUUID().toString();
        String siteId = UUID.randomUUID().toString();
        String noteId = UUID.randomUUID().toString();

        // Prepare offline batch push
        SyncPushRequest pushReq = new SyncPushRequest();

        CustomerDto c = new CustomerDto();
        c.setId(custId);
        c.setName("Offline Generated Customer");
        c.setContactInformation("offline@sync.org");
        pushReq.getCustomers().add(c);

        SiteDto s = new SiteDto();
        s.setId(siteId);
        s.setCustomerId(custId);
        s.setName("Remote Mountain Substation");
        s.setAddress("Mile Marker 42, Ridge Rd");
        pushReq.getSites().add(s);

        FieldNoteDto n = new FieldNoteDto();
        n.setId(noteId);
        n.setSiteId(siteId);
        n.setTitle("Battery Backup Test");
        n.setDescription("Completed 4-hour load test. Voltage stable.");
        n.setStatus("Completed");
        n.setDateTime(Instant.now());
        pushReq.getNotes().add(n);

        // Execute Push Sync
        mockMvc.perform(post("/api/sync/push")
                        .header("Authorization", user1Token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(pushReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.syncedCustomerIds[0]").value(custId))
                .andExpect(jsonPath("$.syncedSiteIds[0]").value(siteId))
                .andExpect(jsonPath("$.syncedNoteIds[0]").value(noteId));

        // Execute Pull Sync (Full pull for new device)
        MvcResult pullResult = mockMvc.perform(get("/api/sync/pull")
                        .header("Authorization", user1Token))
                .andExpect(status().isOk())
                .andReturn();

        SyncPullResponse pullRes = objectMapper.readValue(pullResult.getResponse().getContentAsString(), SyncPullResponse.class);
        assertThat(pullRes.getCustomers()).anyMatch(cust -> cust.getId().equals(custId));
        assertThat(pullRes.getSites()).anyMatch(site -> site.getId().equals(siteId));
        assertThat(pullRes.getNotes()).anyMatch(note -> note.getId().equals(noteId));
    }
}
