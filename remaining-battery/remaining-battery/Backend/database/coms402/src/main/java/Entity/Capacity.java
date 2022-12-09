package Entity;

import javax.persistence.*;
import Entity.Table;

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
public class Capacity {
        //not javax but springframework data
    @Id
    //javax
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long cap_id;
    private long Capacity;
}
