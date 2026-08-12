import { parquetRead, ParquetReadOptions } from "hyparquet";

export class AsyncBuffer {
  private buffer: ArrayBuffer;

  constructor(buffer: ArrayBuffer) {
    this.buffer = buffer;
  }

  async slice(start: number, end: number): Promise<ArrayBuffer> {
    return this.buffer.slice(start, end);
  }

  get byteLength() {
    return this.buffer.byteLength;
  }
}

const parseValue = (value: any, type: "number" | "bigint", fallback?: any): any => {
  if (value === undefined || value === null || value === "") {
    return fallback ?? (type === "bigint" ? BigInt(0) : 0);
  }
  if (typeof value === "string" && value.endsWith("n")) {
    return BigInt(value.slice(0, -1));
  }
  return type === "bigint" ? BigInt(value) : Number(value);
};

const parseArray = (value: any): any[] => (Array.isArray(value) ? value : []);

const parseArrayOrSingle = (value: any): any[] => {
  if (Array.isArray(value)) return value;
  if (value === undefined || value === null || value === "") return [];
  return [value];
};

const parseFindings = (value: any): any[] => {
  if (Array.isArray(value)) return value;
  if (typeof value === "string" && value.trim()) {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }
  return [];
};

export const readParquetFile = async (
  file: File | Blob,
  schema?: string
): Promise<any[]> => {
  try {
    const arrayBuffer = await file.arrayBuffer();
    const asyncBuffer = new AsyncBuffer(arrayBuffer);

    return new Promise((resolve, reject) => {
      const options: ParquetReadOptions = {
        file: asyncBuffer,
        rowFormat: 'object',
        onComplete: (rows: Record<string, any>[]) => {          
          if (schema === "entity") {
            
            resolve(
              rows.map((row) => ({         
                id: row["id"],                
                human_readable_id: parseValue(row["human_readable_id"], "number"),
                title: row["title"],
                type: row["type"],
                description: row["description"],
                text_unit_ids: parseArray(row["text_unit_ids"]),

              }))
            );
          } else if (schema === "relationship") {
            resolve(
              rows.map((row) => ({
                id: row["id"],
                human_readable_id: parseValue(row["human_readable_id"], "number"),                
                source: row["source"],
                target: row["target"],
                description: row["description"],
                weight: parseValue(row["weight"], "number"),
                combined_degree: parseValue(row["combined_degree"], "number"),
                text_unit_ids: parseArray(row["text_unit_ids"]),
                type: "RELATED", // Custom field to match neo4j            
              }))
            );
          } else if (schema === "document") {
            resolve(
              rows.map((row) => ({
                id: row["id"],
                human_readable_id: parseValue(row["human_readable_id"], "number"),                
                title: row["title"],
                text: row["text"],
                text_unit_ids: parseArray(row["text_unit_ids"]),
              }))
            );
          } else if (schema === "text_unit") {
            resolve(
              rows.map((row) => ({
                id: row["id"],
                human_readable_id: parseValue(row["human_readable_id"], "number"),                
                text: row["text"],
                n_tokens: parseValue(row["n_tokens"], "number"),                
                document_ids: parseArrayOrSingle(row["document_ids"] ?? row["document_id"]),
                entity_ids: parseArray(row["entity_ids"]),
                relationship_ids: parseArray(row["relationship_ids"] ?? row["relationships_ids"]),
              }))
            );
          } else if (schema === "community") {
            resolve(
              rows.map((row) => ({
                id: row["id"],
                human_readable_id: parseValue(row["human_readable_id"], "number"),     
                community: parseValue(row["community"], "number"),
                parent: parseValue(row["parent"], "number", undefined),
                level: parseValue(row["level"], "number"),                
                title: row["title"],
                entity_ids: parseArray(row["entity_ids"]),
                relationship_ids: parseArray(row["relationship_ids"]),
                text_unit_ids: parseArray(row["text_unit_ids"]),
                period: row["period"],                
                size: parseValue(row["size"], "number"),
              }))
            );
          } else if (schema === "community_report") {
            resolve(
              rows.map((row) => ({
                id: row["id"],
                human_readable_id: parseValue(row["human_readable_id"], "number"),
                community: parseValue(row["community"], "number"),       
                parent: parseValue(row["parent"], "number", undefined),
                level: parseValue(row["level"], "number"),                
                title: row["title"],
                summary: row["summary"],
                full_content: row["full_content"],
                rank: parseValue(row["rank"], "number"),
                rank_explanation: row["rank_explanation"] ?? row["rating_explanation"],
                findings: parseFindings(row["findings"]),
                full_content_json: row["full_content_json"],
                period: row["period"],                
                size: parseValue(row["size"], "number"),            
              }))
            );
          } else if (schema === "covariate") {
            resolve(
              rows.map((row) => ({
                id: row["id"],
                human_readable_id: parseValue(row["human_readable_id"], "number"),                
                covariate_type: row["covariate_type"],
                type: row["type"],
                description: row["description"],
                subject_id: row["subject_id"],
                object_id: row["object_id"],
                status: row["status"],
                start_date: row["start_date"],
                end_date: row["end_date"],
                source_text: row["source_text"],
                text_unit_id: row["text_unit_id"],              
              }))
            );
          } else {
            resolve(
              rows.map((row: Record<string, any>) => ({
                ...row
              }))
            );
          }
        },
      };
      parquetRead(options).catch(reject);
    });
  } catch (err) {
    console.error("Error reading Parquet file", err);
    return [];
  }
};
