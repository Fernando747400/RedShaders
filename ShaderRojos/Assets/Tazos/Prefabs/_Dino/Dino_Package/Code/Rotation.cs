using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation : MonoBehaviour
{
    public float speed;
    public float yAngle;
    public float xAngle;
    public float zAngle;
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        this.transform.Rotate(xAngle * speed * Time.deltaTime ,yAngle * speed * Time.deltaTime ,zAngle * speed * Time.deltaTime);
    }
}
