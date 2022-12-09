package Entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;

import org.springframework.data.annotation.Id;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Energy {
        //not javax but springframework data
    @Id
    //javax
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long channel_id;
    private long energy;
}
